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
            Exercise.createExercise(context: managedContext, type: .single, name: "Standing barbell shoulder press", numberOfSets: 5, numberOfReps: 5),
            Exercise.createExercise(context: managedContext, type: .single, name: "Plate raises", numberOfSets: 3, numberOfReps: 8),
            Exercise.createExercise(context: managedContext, type: .single, name: "Reverse flies", numberOfSets: 5, numberOfReps: 5),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 10, exerciseDescriptions: ["Some super set", "Seated dumbell shoulder press", "Dumbell lat raises"]),
            Exercise.createExercise(context: managedContext, type: .postLift, name: "25 min swim")
        ]
        
        let _ = Workout.createWorkout(
            context: managedContext,
            workoutTitle: "Monday 1/20 - Chest",
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
