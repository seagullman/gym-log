//
//  ExerciseType.swift
//  gym-log
//
//  Created by Brad Siegel on 1/6/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation


public enum ExerciseType: String, Codable {
    case warmUp = "WarmUp"
    case single = "Single"
    case superSet = "SuperSet"
    case postLift = "PostLift"
}

public struct ExerciseDM: Codable {
    public var type: ExerciseType
    public var name: String?
    public var numberOfSets: Int?
    public var numberOfReps: Int?
    public var exerciseDescriptions: [String]?
}

let singleExercise = ExerciseDM(
    type: ExerciseType.warmUp,
    name: "20 min elliptical"
);

public struct WorkoutDM: Codable {
    public var exercises: [ExerciseDM]
}





