//
//  AddWorkoutViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/15/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import CoreData

public protocol AddWorkoutDelegate: class {
    func workoutSaved()
}


public class AddWorkoutViewController: UIViewController {
    
    public var delegate: AddWorkoutDelegate?
    
    @IBAction func saveWorkout() {
        let managedContext = AppDelegate.viewContext
        let exercises = [
            Exercise.createExercise(context: managedContext, type: .warmUp, name: "5 min Elliptical"),
            Exercise.createExercise(context: managedContext, type: .single, name: "Close Grip Bench Press", numberOfSets: 5, numberOfReps: 5),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 10, exerciseDescriptions: ["Standing EZ Bar Curls", "Skull Crushers"]),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 8, exerciseDescriptions: ["Straight Bar Cable Curls", "Straight Bar Tricep Pushdowns"]),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 12, exerciseDescriptions: ["Standing Single Arm Dumbbell Curls", "Overhead Tricep Extensions"]),
            Exercise.createExercise(context: managedContext, type: .postLift, name: "20-25 min swim")
        ]
        
        let _ = Workout.createWorkout(
            context: managedContext,
            workoutTitle: "Wednesday 1/22 - Arms",
            exercises: exercises
        )
        
        self.delegate?.workoutSaved()
        self.presentingViewController?.dismiss(animated: true)
    }
    
    private func deleteDatabase(_ managedContext: NSManagedObjectContext) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
            print("Deleted")
            
        } catch {
            // Error Handling
        }
    }

}
