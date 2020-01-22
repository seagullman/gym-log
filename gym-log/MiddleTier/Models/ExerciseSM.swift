//
//  ExerciseSM.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation


public protocol ExerciseSM {
    var name: String { get }
    var managedObject: Exercise { get }
    var completed: Bool { get }
}

public struct WarmUpExerciseSM: ExerciseSM {
    
    private let exerciseDM: Exercise
    
    public init(exerciseDM: Exercise) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        guard let _type = ExerciseType(rawValue: self.exerciseDM.type) else {
            NSLog("***** FATAL ERROR: invalid ExerciseType fetched")
            abort()
        }
        
        return _type
    }
    
    public var typeString: String {
        return "Warm Up" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var completed: Bool {
        return self.exerciseDM.completed
    }
    
    public var managedObject: Exercise {
        return self.exerciseDM
    }
}

public struct SingleExerciseSM: ExerciseSM {
    
    private let exerciseDM: Exercise
    
    public init(exerciseDM: Exercise) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        guard let _type = ExerciseType(rawValue: self.exerciseDM.type) else {
            NSLog("***** FATAL ERROR: invalid ExerciseType fetched")
            abort()
        }
        
        return _type
    }
    
    public var typeString: String {
        return "Single" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var completed: Bool {
         return self.exerciseDM.completed
     }
    
    public var numberOfSets: String {
        let sets = self.exerciseDM.numberOfSets
        if (sets == 0) { return "" }
        
        return String(sets)
    }
    
    public var numberOfReps: String {
        let reps = self.exerciseDM.numberOfReps
        if (reps == 0) { return "" }
        return String(reps)
    }
    
    public var managedObject: Exercise {
        return self.exerciseDM
    }
    
}

public struct SuperSetExerciseSM: ExerciseSM {
    
    private let exerciseDM: Exercise
    
    public init(exerciseDM: Exercise) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        guard let _type = ExerciseType(rawValue: self.exerciseDM.type) else {
            NSLog("***** FATAL ERROR: invalid ExerciseType fetched")
            abort()
        }
        
        return _type
    }
    
    public var typeString: String {
        return "Super Set" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var completed: Bool {
         return self.exerciseDM.completed
     }
    
    public var numberOfSets: String {
        let sets = self.exerciseDM.numberOfSets
        if (sets == 0) { return "" }
        
        return String(sets)
    }
    
    public var numberOfReps: String {
        let reps = self.exerciseDM.numberOfReps
        if (reps == 0) { return "" }
        return String(reps)
    }
    
    public var managedObject: Exercise {
        return self.exerciseDM
    }
    
    public var exerciseDescriptions: [String] {
        guard
            let _descriptions = self.exerciseDM.exerciseDescriptions,
            let descriptionObjs: [ExerciseDescription] = _descriptions.allObjects as? [ExerciseDescription]
        else { return [] }
        
        var stringArray: [String] = []
        descriptionObjs.forEach { (desc) in
            guard let description = desc.exerciseDescription else { return }
            
            stringArray.append(description)
        }

        return stringArray
    }
    
}

public struct PostLiftExerciseSM: ExerciseSM {
    
    private let exerciseDM: Exercise
    
    public init(exerciseDM: Exercise) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        guard let _type = ExerciseType(rawValue: self.exerciseDM.type) else {
            NSLog("***** FATAL ERROR: invalid ExerciseType fetched")
            abort()
        }
        
        return _type
    }
    
    public var managedObject: Exercise {
        return self.exerciseDM
    }
    
    public var typeString: String {
        return "Post Lift" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var completed: Bool {
         return self.exerciseDM.completed
     }
    
}
