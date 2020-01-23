//
//  ReadWorkoutDetailsCommand.swift
//  gym-log
//
//  Created by Brad Siegel on 1/23/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public class ReadWorkoutDetailsCommand {
    
    public var lookupKey: UUID?
    
    private let readWorkout: ((UUID) -> FutureResult<Workout>)
    
    internal init(workoutReader: @escaping (UUID) -> FutureResult<Workout>) {
        self.readWorkout = workoutReader
    }
    
    public convenience init() {
        let client = CoreDataGymLogClient.shared
        let workoutsReader = client.fetchWorkoutDetails
        self.init(workoutReader: workoutsReader)
    }
    
    public func execute() -> FutureResult<WorkoutDetailsDataSource> {
        guard let id = self.lookupKey else {
            NSLog("***** ERROR: ReadWorkoutDetailsCommand --> lookupKey not set")
            abort()
        }
        
        let readWorkout = self.readWorkout(id)
            .pipe(into: self.convertToArray(workout:))
            .pipe(into: convertToWorkoutScreenModels(workouts:))
            .pipe(into: createWorkoutDetailsDataSource(withWorkout:))
        return readWorkout
    }
    
    // MARK: Private functions
    
    private func convertToArray(workout: Workout) -> FutureResult<[Workout]> {
        let deferred = DeferredResult<[Workout]>()
        let workoutArray = [workout]
        deferred.success(value: workoutArray)
        return deferred
    }
}
