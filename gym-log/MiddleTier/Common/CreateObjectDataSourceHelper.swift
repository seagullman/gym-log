//
//  CreateObjectDataSourceHelper.swift
//  gym-log
//
//  Created by Brad Siegel on 1/16/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


internal func createArrayObjectDataSource<T>(withScreenModels models: [T]) -> FutureResult<ObjectDataSource<T>> {
    let deferred = DeferredResult<ObjectDataSource<T>>()
    let dataSource = ArrayObjectDataSource(objects: models)
    deferred.success(value: dataSource)
    return deferred
}

internal func createCustomDataSource(withWorkout workout: WorkoutScreenModel) -> FutureResult<WorkoutDataSource> {
    let deferred = DeferredResult<WorkoutDataSource>()
    if let _workout = workout as? WorkoutSM {
        let dataSource = WorkoutDataSource(workoutSM: _workout, exercises: _workout.exercises)
        deferred.success(value: dataSource)
    } else {
        let dataSource = WorkoutDataSource(exercises: [])
        deferred.success(value: dataSource)
    }
    
    return deferred
}

internal func createWorkoutDetailsDataSource(withWorkout workout: WorkoutScreenModel) -> FutureResult<WorkoutDetailsDataSource> {
    let deferred = DeferredResult<WorkoutDetailsDataSource>()
    if let _workout = workout as? WorkoutSM {
        let dataSource = WorkoutDetailsDataSource(workoutSM: _workout)
        deferred.success(value: dataSource)
    } else {
        let dataSource = WorkoutDetailsDataSource(workoutSM: WorkoutStubSM())
        deferred.success(value: dataSource)
    }
    
    return deferred
}

internal func convertToWorkoutScreenModels(workouts: [Workout]) -> FutureResult<WorkoutScreenModel> {
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
