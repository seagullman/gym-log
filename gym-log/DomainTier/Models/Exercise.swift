//
//  Exercise.swift
//  gym-log
//
//  Created by Brad Siegel on 1/13/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import CoreData

public enum ExerciseType: Int16 {
    case warmUp = 0
    case single = 1
    case superSet = 2
    case postLift = 3
}

public class Exercise: NSManagedObject {
    
    class func createExercise(
        context: NSManagedObjectContext,
        type: ExerciseType,
        name: String? = nil,
        numberOfSets: Int16? = nil,
        numberOfReps: Int16? = nil,
        exerciseDescriptions: [String]? = nil
    ) -> Exercise {
         
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.type = type.rawValue
        exercise.name = name
        exercise.date = Date()
        exercise.completed = false
        
        var set = NSSet()
        if let descriptions = exerciseDescriptions {
            let descriptionObjs = descriptions.map { (descriptionString) -> ExerciseDescription in
                let description = ExerciseDescription(context: context)
                description.exerciseDescription = descriptionString
                exercise.addToExerciseDescriptions(description)
                return description
            }
            set = set.addingObjects(from: descriptionObjs) as NSSet
        }
        
        if
            let sets = numberOfSets,
            let reps = numberOfReps {
            exercise.numberOfSets = sets
            exercise.numberOfReps = reps
            
        }

        
        return exercise
    }
}

