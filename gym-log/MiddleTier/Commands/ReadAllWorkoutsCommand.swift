//
//  ReadAllWorkoutsCommand.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public class ReadAllWorkoutsCommand {

    private let readWorkouts: (() -> FutureResult<[Workout]>)
    
    internal init(workoutReader: @escaping () -> FutureResult<[Workout]>) {
        self.readWorkouts = workoutReader
    }
    
    public convenience init() {
        let client = CoreDataGymLogClient.shared
        let workoutsReader = client.fetchAllWorkouts
        self.init(workoutReader: workoutsReader)
    }
    
    public func execute() -> FutureResult<ObjectDataSource<WorkoutSM>> {
        let readWorkout = self.readWorkouts()
            .pipe(into: self.convertToScreenModels(workouts:))
            .pipe(into: createArrayObjectDataSource(withScreenModels:))
        return readWorkout
    }
    
    private func convertToScreenModels(workouts: [Workout]) -> FutureResult<[WorkoutSM]> {
        let deferred = DeferredResult<[WorkoutSM]>()
        let screenModels = workouts.map { WorkoutSM(workout: $0) }
        deferred.success(value: screenModels)
        return deferred
    }
    
}
