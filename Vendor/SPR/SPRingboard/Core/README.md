SPRingboard Core
================

SPRingboard Core components only have dependencies on the [Swift core 
libraries][SCL] (hence the name): Foundation, libdispatch, and XCTest. Thus, 
the components are reusable across all of Apple's platforms that support Swift. 
These components should also be usable on Linux and other platforms that 
support Swift, but that is not a design goal of this project and testing on 
those platforms is out of scope. 


Asynchronous Programming
------------------------

The majority of the components in SPRingboard Core are dedicated to handling 
asynchronous programming. 

There are numerous open source libraries already available to simplify 
asynchronous programming. Unfortunately, most of these libraries did not pass 
SPR's code quality review and the high-quality libraries (such as 
[PromiseKit][PKT] and [Deferred][DEF]) almost all have _very_ complex 
implementations to support advanced capabilities that SPR has rarely needed on 
its projects. Thus, SPR has found it necessary to implement its own 
asynchronous programming components. 

### Future and Deferred

A `Future` is container that will be asynchronously filled with a value. An 
asynchronous function can synchronously return a future, then fill the future 
later when its asynchronous operations complete. 

A future is only filled _once._ Handlers attached to the future before the 
value is filled are executed at the time the handler is filled. Handlers 
attached after the future has been filled are executed immediately. 

`Deferred` is a subclass of `Future` that provides a mechanism to fill the 
future's value. 

Your asynchronous method signatures will return a `Future`. The implementation 
of those methods will create and return a `Deferred`, then fill the `Deferred` 
when the value is available. In this manner you prevent code that calls your 
asynchronous function from being able to fill the `Future` — it can only attach 
value handlers. 

Handlers are attached to a `Future` using the `then(upon:run:)` method. The 
`upon` parameter is a `DispatchQueue` and defaults to the main queue if 
unspecified. The `run` parameter is a function reference or block with a single 
parameter of the type contained by the `Future` and returns `Void`. 

Example:

    func calculateFibonacciNumber(_ index: UInt8) -> Future<UInt64> {
        let deferred = Deferred<UInt64>()
        DispatchQueue.global().async {
            if index == 0 {
                deferred.fill(value: 0)
            } else if index == 1 || index == 2 {
                deferred.fill(value: 1)
            } else {
                var currentIndex: UInt64 = 3
                var currentValue: UInt64 = 2
                var previousValue: UInt64 = 1
                
                while currentIndex < index {
                    let nextValue = previousValue + currentValue
                    previousValue = currentValue
                    currentValue = nextValue
                    currentIndex += 1
                }
                deferred.fill(value: currentValue)
            }
        }
        return deferred
    }
    
    @IBAction func showFibonacci63(sender: AnyObject) {
    	self.button.isEnabled = false
        let future = calculateFibonacciNumber(63)
        future.then { [weak self] (number) in 
            self?.label?.text = "\(number)"
            self?.button?.isEnabled = true
        }
    }
    
#### Chaining Futures

Futures can be chained together using the `pipe(upon:into:)` method. The 
`upon` parameter is a `DispatchQueue` and defaults to the main queue if 
unspecified. The `into` parameter is a function reference or block with a 
single parameter of the type contained by the `Future` and returning a 
`Future` or value.

That is a mouthful, so let me state that a different way: any function or block 
of the following forms can be chained together: 

- `(InputType) -> Future<OutputType>`
- `(InputType) -> OutputType`

Notice that complex business logic can be composed of many little functions 
that match those signatures. Those small functions, having clear inputs and 
outputs, are easy to test! This encourages building large solutions by writing 
lots of small functions. 

Example:

    ///////////////////////////////////////////////////////////////////////
	// Functions that can be chained together 
	
    func calculateFibonacciNumber(_ index: UInt8) -> Future<UInt64> {
        // implementation is the same as before
    }
    
    func findFactors(value: UInt64) -> Future<[UInt64]> {
        let deferred = Deferred<[UInt64]>()
        
        DispatchQueue.global().async {
            let squareRoot = UInt64(sqrt(Double(value)))
            let factors: [UInt64] = (1...squareRoot).filter({ value % $0 == 0 }).flatMap({ [ $0, value / $0 ] }).sorted()
            deferred.fill(value: factors)
        }
        
        return deferred
    }
    
    func sum(of values: [UInt64]) -> UInt64 {
        return values.reduce(0, { $0 + $1 })
    }
    
    ///////////////////////////////////////////////////////////////////////
	// Function that show how to chain the above functions together 
	
    func sumOfFactorsForFibonacciNumber(_ index: UInt8) -> Future<UInt64> {
        let future = calculateFibonacciNumber(index)
                     .then(pipeInto: self.findFactors(value:))
                     .then(pipeInto: self.sum(of:))
        return future
    }

### Result

Most asynchronous operations for iOS apps, such as network requests, might  
fail. Since asynchronous operations cannot make use of Swift's built-in error 
handling using `throws`, it is necessary for asynchronous completion 
handlers to accept both successful outcomes and errors indicating failure. 
For these cases, use `Result`: an `enum` with `success` and `failure` cases 
wrapping associated objects for the successfully derived value or the `Error` 
that caused the asynchronous activity to fail. 

Example:

    func loadSwiftOrgHTML(completion: @escaping (Result<String>) -> Void) {
        let url = URL(string: "https://swift.org")!
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                
                completion(.success(html))
            } else {
                let loadError = LoadError.invalidResponse
                completion(.failure(loadError))
            }
        }
        task.resume()
    }
    
    @IBAction func showSwiftOrgHTML(sender: AnyObject?) {
        loadSwiftOrgHTML { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let html): 
                    self?.webview?.loadHTMLString(html, baseURL: nil)
                case .failure(let error): 
                    let message = String(describing: error)
                    self?.errorLabel?.text = message
				}
			}
		}
	}
	
### ResultHandler

Once you start using `Result` in asynchronous completion handlers, you start 
writing a lot of completion handler parameters of type `(Result<Foo>) -> Void`. 
The `ResultHandler` type alias simplifies writing these parameters. 

For example, the `loadSwiftOrgHTML` function in previous section could be 
defined as:

    func loadSwiftOrgHTML(completion: @escaping ResultHandler<String>) {
        // implementation is the same as before
    }
        
### FutureResult and DeferredResult

Using all of the ideas above, you might anticipate writing a lot of 
asynchronous methods that return a `Future` of a `Result`, such as:

    func loadSwiftOrgHTML() -> Future<Result<String>> {
        // ...
    }

However, when you look at chaining a number of these methods together, you 
usually want to stop processing downstream functions in the chain as soon as 
any function fills with a `.failure` result. The `FutureResult` type implements 
this behavior, saving you from writing the boilerplate code over and over. 

`DeferredResult` is a subclass of `FutureResult` that provides a mechanism to 
fill the future's `Result`. 

Your asynchronous method signatures will return a `FutureResult`. The 
implementation of those methods will create and return a `DeferredResult`, then 
fill the `DeferredResult` when the `Result` is available. In this manner you 
prevent code that calls your asynchronous function from being able to fill the 
`Futureresult` — it can only attach `ResultHandler`s. 

Handlers are attached to a `FutureResult` using the `then(upon:handleResult:)` 
method. The `upon` parameter is a `DispatchQueue` and defaults to the main 
queue if unspecified. The `handleResult` parameter is a `ResultHandler` for the 
success type of the future's result.

Example:

    func loadSwiftOrgHTML() -> FutureResult<String> {
        let deferred = DeferredResult<String>()
        let url = URL(string: "https://swift.org")!
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                deferred.failure(error: error)
            } else if
                let data = data,
                let html = String(data: data, encoding: .utf8) {
                
                deferred.success(value: html)
            } else {
                let loadError = LoadError.invalidResponse
                deferred.failure(error: loadError)
            }
        }
        task.resume()
        
        return deferred
    }
    
    @IBAction func showSwiftOrgHTML(sender: AnyObject?) {
        loadSwiftOrgHTML().then { [weak self] (result) in
			switch result {
			case .success(let html): 
				self?.webview?.loadHTMLString(html, baseURL: nil)
			case .failure(let error): 
				let message = String(describing: error)
				self?.errorLabel?.text = message
			}
		}
	}
	
#### Chaining FutureResults

What makes `FutureResult` more powerful than `Future<Result>` is the automatic 
handling of failures when `FutureResult`s are chained together using the 
`pipe(upon:into:)` method. The `upon` parameter is a `DispatchQueue` and 
defaults to the main queue if unspecified. The `into` parameter is a 
function reference or block with a single parameter of the _success type_ for 
the `Result` contained by the `FutureResult` and returning a `FutureResult`. 

That is a mouthful, so let me state that a different way: any function or block 
of the following forms can be chained together: 

- `(InputType) -> FutureResult<OutputType>`
- `(InputType) throws -> Future<OutputType>`
- `(InputType) -> Future<OutputType>`
- `(InputType) throws -> OutputType`
- `(InputType) -> OutputType`

Additionally, there are many other functions to help handle common scenarios 
including filtering, mapping, and timeouts. 

If any function in the chain `throws` or generates a failure `Result`, the 
remaining functions in the chain are skipped and the result handlers for the 
chain's result will be invoked with a `Result.failure` containing the error 
that was thrown or caused the failure. 

Notice that complex business logic can be composed of many little functions 
that match those signatures. Those small functions, having clear inputs and 
outputs, are easy to test! This encourages building large solutions by writing 
lots of small functions. 

Example:

    @IBAction func searchForInStockBooks(sender: AnyObject?) {
        guard let query = self.queryField.text else { return }
        
        self.webclient.findBooks(query)                 // -> FutureResult<[BookModel]>
        .timeoutAfter(interval: 10.0)                   // -> FutureResult<[BookModel]>
        .pipe(into: self.datastore.saveBooks(_:))       // -> FutureResult<[BookModel]>
        .filter(self.isBookInStock(_:))                 // -> FutureResult<[BookModel]>
        .map(self.convertBookModelToBookViewMaster(_:)) // -> FutureResult<[BookViewMaster]>
        .then(handleResult: self.updateTableView(_:))
    }    
    

ObjectDataSource
----------------

SPR's experience maintaining mobile apps over multiple years has impressed upon 
us the importance of decoupling an app's view concerns and object model from 
the server's API and object model to allow the UI, the service APIs, and the 
on-device data storage technologies to evolve independently with minimal impact 
on each other. 

Converting a domain model returned from a service call into a value object for 
a UI's detail view is simple enough, but handling lists is more complicated. 
Data store technologies each have constructs to minimize memory usage when 
handling large result sets; for example, Realm's `Results<Element>`, Core 
Data's `NSFetchedResultController`, and SQLite's `sqlite3_step(sqlite3_stmt*)`. 
To decouple an app's UI layer from its data storage technology requires 
wrapping the data storage technology's result set type. An easy solution is to 
load the results into an array and return the array. However, that is not 
memory efficient and throws away memory and performance optimizations 
implemented in the data storage technology. Instead, SPR created an 
`ObjectDataSource` type as an adapter between the UI and the data storage 
technology. 

`ObjectDataSource` ("ODS") provides an implementation-agnostic adapter for 
managing object collections generated by underlying data storage technologies. 
The `ObjectDataSource` API is designed for ease of use within
`UICollectionViewDataSource` and `UITableViewDataSource` implementations.

SPRingboard Core provides several useful implementations of `ObjectDataSource`: 

- `ArrayObjectDataSource` is an adapter for an array of objects. This is useful 
  for providing fixture data and when handling a data storage technology that 
  lacks its own `ObjectDataSource` implementation.
- `ConcatenatingObjectDataSource` is an adapter that wraps multiple ODS objects
  and presents them as a single `ObjectDataSource`. 
- `ErrorObjectDataSource` is an ODS that reports it has one section with one 
  object and throws a specified error when asked for that object. It turns out 
  this is sometimes an effective way to have a `UITableView` display an error 
  that prevented the real data from being available for display. 
- `TransformingObjectDataSource` is an adapter that wraps an ODS and calls a 
  transform function on each object in that ODS. This is useful for 
  transforming domain models provided by an ODS adapting an data storage 
  technology's result list. 
  

Utilities
---------

To be written.

### Debouncer

To be written.



[DEF]: https://github.com/bignerdranch/Deferred
[PKT]: https://github.com/mxcl/PromiseKit
[SCL]: https://swift.org/core-libraries/
