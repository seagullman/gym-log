//
//  ViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/6/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("viewWillAppear")
        let client = NetworkGymLogClient()
        client.fetchTodaysWorkout() { result in
            switch result {
            case .success(let response):
                NSLog("Exercise count: \(response.exercises.count)")
                self.displayWorkout(workout: response)
            case .failure(let error):
                NSLog("There was an error \(error)")
            }
        }
    }
    
    private func displayWorkout(workout: WorkoutDM) {
        workout.exercises.forEach { (exercise) in
            switch exercise.type {
            case .warmUp:
                NSLog("\(exercise.type)")
                NSLog("\(exercise.name ?? "")")
            case .single:
                NSLog("\(exercise.numberOfSets ?? 0)x\(exercise.numberOfReps ?? 0)")
                NSLog("\(exercise.name ?? "")")
            case .superSet:
                NSLog("\(exercise.type) \(exercise.numberOfSets ?? 0)x\(exercise.numberOfReps ?? 0)")
                exercise.exerciseDescriptions?.forEach({ (description) in
                    NSLog(description)
                })
            case .postLift:
                NSLog("\(exercise.type)")
                NSLog("\(exercise.name ?? "")")
            }
        }
    }


}

