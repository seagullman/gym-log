//
//  GymLogNetworkClient.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation


internal protocol GymLogClient {
    func fetchTodaysWorkout(completion: (AsyncResult<WorkoutDM>) -> Void)
}

internal class NetworkGymLogClient: GymLogClient {
    
    func fetchTodaysWorkout(completion: (AsyncResult<WorkoutDM>) -> Void) {
        NSLog("***** fetching current workout")
        guard let sampleJson = readJSONFromFile(fileName: "exercises") else { return }
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sampleJson)
            let exerciseDMs = try! JSONDecoder().decode(Array<ExerciseDM>.self, from: jsonData)
            let workout = WorkoutDM(exercises: exerciseDMs)
            completion(.success(workout))
        } catch let error {
            NSLog("Error serializing sample json: \(error)")
        }
        
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
