SPRingboard iOS
===============

SPRingboard iOS components rely on SPRingboard Core and the iOS platform
frameworks. The iOS components accelerate mobile app development by encouraging
best practices and reducing boilerplate for common use cases and implementation
patterns. 


SPRViewController
-----------------

The core of SPRingboard iOS is `SPRViewController`. `SPRViewController` was
inspired by the realization that most view controller logic boils down to:
fetch models, update UI with models. However, most online training provides
incorrect guidance as to when models should be fetched (suggesting
`viewDidLoad` instead of `viewWillAppear` ). Additionally, when the models are
loaded asynchronously there is a lot of state management required by the view
controller to operate properly in all cases, including app backgrounding and
the view controller going off screen then reloading its view. This leads to a
lot of boilerplate code that can be written and tested once, and reused
thereafter. `SPRViewController` is the culmination of that work. 

### Loading and Displaying Models

View controllers that subclass `SPRViewController` are primarily concerned with 
overriding three methods:

1.  `loadModel() -> FutureResult<Any>` - called whenever the view controller 
    determines that its model is missing or might be outdated. 
2.  `updateViewWithModel(_:)` - called whenever the view controller
    determines that its view may be out of sync with its model.
3.  `handleError(_:)` - called instead of `updateViewWithModel(_:)` when 
    `loadModel()` fails (i.e., the `FutureResult` is filled with a failure 
    `Result`). 

Using on these methods, `SPRViewController` subclasses can focus on
implementing the view controller's key business logic instead of juggling
`UIViewController` state callbacks. 

### Other Capabilities

Additionally, `SPRViewController` has methods that subclasses can override to 
implement other useful behaviors. 

To display an activity indicator when the model is loaded asynchronously and
hide it again when the view has been updated with the model's information,
override `loadingActivityPresenter()`. You can implement your own
`SPRViewControllerActivityPresenter` or use the one in SPRingboard:
`FullScreenActivityPresenter`. 

To disable form elements, such as a "Submit" button when the model is loaded
asynchronously, and re-enable them when the view has been updated with the
model's information, override the `disableControls()` and `enableControls()` 
methods, respectively. 

### More Information 

Read the Swift API documentation for `SPRViewController` to learn more and see 
examples. 


SPRCollectionViewController & SPRTableViewController
----------------------------------------------------

Managing data sources for collection views and table views presents additional
challenges beyond what `SPRViewController` is designed to handle. For those 
cases, `SPRCollectionViewController` and `SPRTableViewController` should be 
used. 

For developers implementing subclasses, these view controllers hide the
additional complexity and provide an API nearly identical to
`SPRViewController`. Below are the differences:

- Instead of `loadModels()`, subclasses must override `loadObjectDataSource()
  -> FutureResult<ObjectDataSource<Any>>`. 
- Instead of `updateViewWithModel(_:)`, subclasses must override the following 
  _two_ methods:
  1.  `renderCell(in:withModel:at:) throws -> UITableViewCell` - called when 
      backing object data source returned an object for the specified index 
      path.
  2.  `renderCell(in:withError:at:) -> UITableViewCell` - called when the 
      backing object data source threw an error instead of returning an object
      for the specified index path and when `renderCell(in:withModel:at:)` 
      throws an error. 
      
Subclasses should _also_ still override `handleError(_:)` to handle the case 
when `loadObjectDataSource()` fails. 

