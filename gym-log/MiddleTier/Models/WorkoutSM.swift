
//
//  WorkoutSM.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation

public protocol WorkoutScreenModel {
    
}


public struct WorkoutSM: WorkoutScreenModel {
    
    private let workout: Workout
    private var exerciseSMs: [ExerciseSM] = []
    
    public init(workout: Workout) {
        self.workout = workout
        self.exerciseSMs = self.generateExerciseSMs()
    }
    
    public var title: String {
        return self.workout.title ?? ""
    }
    
    public var date: String {
        guard let _date = self.workout.date else { return "" }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/dd"
        return dateFormatterGet.string(from: _date)
    }
    
    public var exercises: [ExerciseSM] {
        return self.exerciseSMs
    }
    
    // MARK: Private Funcions
    
    private func generateExerciseSMs() -> [ExerciseSM] {
        guard
            let _exercises = self.workout.exercises,
            let array: [Exercise] = _exercises.allObjects as? [Exercise]
        else { return [] }
        
        let sortedArray = array.sorted(by: { $0.date! < $1.date! })
        let screenModels = sortedArray.map { (exercise) -> ExerciseSM in
            guard let type = ExerciseType(rawValue: exercise.type) else {
                NSLog("***** FATAL ERROR: array.map --> invalid exercise type fetched")
                abort()
            }
            
            switch type {
            case .warmUp:
                return WarmUpExerciseSM(exerciseDM: exercise)
            case .single:
                return SingleExerciseSM(exerciseDM: exercise)
            case .superSet:
                return SuperSetExerciseSM(exerciseDM: exercise)
            case .postLift:
                return PostLiftExerciseSM(exerciseDM: exercise)
            }
        }
        return screenModels
    }
}

public struct WorkoutStubSM: WorkoutScreenModel {
    
    
}
