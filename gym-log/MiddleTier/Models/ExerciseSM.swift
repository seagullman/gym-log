//
//  ExerciseSM.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation


public protocol ExerciseSM {}

public struct WarmUpExerciseSM: ExerciseSM {
    
    private let exerciseDM: ExerciseDM
    
    public init(exerciseDM: ExerciseDM) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        return self.exerciseDM.type
    }
    
    public var typeString: String {
        return "Warm Up" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
}

public struct SingleExerciseSM: ExerciseSM {
    
    private let exerciseDM: ExerciseDM
    
    public init(exerciseDM: ExerciseDM) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        return self.exerciseDM.type
    }
    
    public var typeString: String {
        return "Single" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var numberOfSets: String {
        guard let sets = self.exerciseDM.numberOfSets else { return "" }
        
        return String(sets)
    }
    
    public var numberOfReps: String {
        guard let reps = self.exerciseDM.numberOfReps else { return "" }
        
        return String(reps)
    }
    
}

public struct SuperSetExerciseSM: ExerciseSM {
    
    private let exerciseDM: ExerciseDM
    
    public init(exerciseDM: ExerciseDM) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        return self.exerciseDM.type
    }
    
    public var typeString: String {
        return "Super Set" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
    public var numberOfSets: String {
        guard let sets = self.exerciseDM.numberOfSets else { return "" }
        
        return String(sets)
    }
    
    public var numberOfReps: String {
        guard let reps = self.exerciseDM.numberOfReps else { return "" }
        
        return String(reps)
    }
    
    public var exerciseDescriptions: [String] {
        guard let descriptions = self.exerciseDM.exerciseDescriptions else { return [] }
        
        return descriptions
    }
    
}

public struct PostLiftExerciseSM: ExerciseSM {
    
    private let exerciseDM: ExerciseDM
    
    public init(exerciseDM: ExerciseDM) {
        self.exerciseDM = exerciseDM
    }
    
    public var type: ExerciseType {
        return self.exerciseDM.type
    }
    
    public var typeString: String {
        return "Post Lift" // TODO: move this to constants file
    }
    
    public var name: String {
        return self.exerciseDM.name ?? ""
    }
    
}
