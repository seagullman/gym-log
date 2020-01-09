//
//  GymLogNetworkClient.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard

internal protocol GymLogClient {
    func fetchWorkout() -> FutureResult<WorkoutResponse>
}

fileprivate let sharedNetworkClient = NetworkGymLogClient()

internal class NetworkGymLogClient: GymLogClient {
    
    public static let shared: NetworkGymLogClient = sharedNetworkClient
    
    func fetchWorkout() -> FutureResult<WorkoutResponse> {
        NSLog("***** fetching current workout")
        let deferred = DeferredResult<WorkoutResponse>()
        
        guard let sampleJson = readJSONFromFile(fileName: "exercises") else {
            NSLog("***** FATAL ERROR: Unable to read workout JSON from file")
            fatalError()
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sampleJson)
            let response = try! JSONDecoder().decode(WorkoutResponse.self, from: jsonData)
            deferred.success(value: response)
        } catch let error {
            NSLog("Error serializing sample json: \(error)")
            deferred.failure(error: error)
        }
        return deferred
    }
    
    func readJSONFromFile(fileName: String) -> Any? {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
            } catch {
                // Handle error here
            }
        }
        return json
    }
}
    

