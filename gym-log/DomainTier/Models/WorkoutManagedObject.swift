//
//  WorkoutManagedObject.swift
//  gym-log
//
//  Created by Brad Siegel on 1/15/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import CoreData

public class Workout: NSManagedObject {

    class func createWorkout(context: NSManagedObjectContext, workoutTitle: String, exercises: [Exercise]) {
        context.perform {
            let workout = Workout(context: context)
            workout.id = UUID()
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            workout.date = Date()
            workout.title = workoutTitle
            workout.addToExercises(NSSet(array: exercises))
            workout.completed = false
            
            do {
                try context.save()
                print("WORKOUT SAVED")
            } catch  {
                print("ERROR SAVING WORKOUT")
            }
        }
    }
}
