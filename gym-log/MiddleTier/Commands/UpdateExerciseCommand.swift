//
//  UpdateExerciseCommand.swift
//  gym-log
//
//  Created by Brad Siegel on 1/20/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public class UpdateExerciseCommand {
    
    private let updateExercise: ((Exercise, Bool) -> FutureResult<Bool>)
    public var exercise: Exercise?
    public var completed: Bool?
    
    internal init(updateExercise: @escaping (Exercise, Bool) -> FutureResult<Bool>) {
        self.updateExercise = updateExercise
    }
    
    public convenience init() {
        let client = CoreDataGymLogClient.shared
        let exerciseUpdater = client.toggleExerciseCompleted
        self.init(updateExercise: exerciseUpdater)
    }
    
    public func execute() -> FutureResult<Bool> {
        guard
            let exercise = self.exercise,
            let completed = self.completed
        else {
            let deferred = DeferredResult<Bool>()
            deferred.failure(error: GymLogError.missingValueForPropertyError(message: "self.exercise or self.exercise is nil"))
            return deferred
        }
        
        return self.updateExercise(exercise, completed)
    }
    
    // MARK: Private Functions
    
//    private func parseWorkout(workouts: [Workout]) -> FutureResult<Workout> {
//        let deferred = DeferredResult<Workout>()
//        deferred.success(value: workouts[0])
//        return deferred
//    }
}
