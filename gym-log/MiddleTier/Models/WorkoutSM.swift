
//
//  WorkoutSM.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation


public struct WorkoutSM {
    
    private let workoutTitle: String
    private let _exerciseSMs: [ExerciseSM]
    
    public init(workoutTitle: String, exercises: [ExerciseDM]) {
        self.workoutTitle = workoutTitle
        
        self._exerciseSMs = exercises.map { (exerciseDM) -> ExerciseSM in
            switch exerciseDM.type {
            case .warmUp:
                return WarmUpExerciseSM(exerciseDM: exerciseDM)
            case .single:
                return SingleExerciseSM(exerciseDM: exerciseDM)
            case .superSet:
                return SuperSetExerciseSM(exerciseDM: exerciseDM)
            case .postLift:
                return PostLiftExerciseSM(exerciseDM: exerciseDM)
            }
        }
    }
    
    public var title: String {
        return self.workoutTitle
    }
    
    public var exerciseSMs: [ExerciseSM] {
        return self._exerciseSMs
    }
}
