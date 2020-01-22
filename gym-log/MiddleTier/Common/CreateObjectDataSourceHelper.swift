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
