//
//  ReadTodaysWorkoutsCommand.swift
//  gym-log
//
//  Created by Brad Siegel on 1/16/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public class ReadTodaysWorkoutsCommand {
    
    private let readWorkout: (() -> FutureResult<[Workout]>)
    
    internal init(workoutReader: @escaping () -> FutureResult<[Workout]>) {
        self.readWorkout = workoutReader
    }
    
    public convenience init() {
        let client = CoreDataGymLogClient.shared
        let workoutsReader = client.fetchTodaysWorkout
        self.init(workoutReader: workoutsReader)
    }
    
    public func execute() -> FutureResult<WorkoutDataSource> {
        let readWorkout = self.readWorkout()
            .pipe(into: self.convertToScreenModels(workouts:))
            .pipe(into: createCustomDataSource(withWorkout:))
        return readWorkout
    }
    
    private func convertToScreenModels(workouts: [Workout]) -> FutureResult<WorkoutScreenModel> {
        let deferred = DeferredResult<WorkoutScreenModel>()
        if (workouts.count == 0) {
            // This is needed so the WorkoutObjectDataSource can be initialized
            // when there are no workoutouts entered. This will be used by the
            // UITableView to show the EmptyWorkoutView
            let emptyWorkoutStub = WorkoutStubSM()
            deferred.success(value: emptyWorkoutStub)
        } else {
            let workoutModel = workouts.map { WorkoutSM(workout: $0) }
            deferred.success(value: workoutModel[0])
        }
        return deferred
    }
}
