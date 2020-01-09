//
//  ReadWorkoutCommand.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public class ReadWorkoutCommand {

    private let readWorkout: (() -> FutureResult<WorkoutResponse>)
    
    internal init(workoutReader: @escaping () -> FutureResult<WorkoutResponse>) {
        self.readWorkout = workoutReader
    }
    
    public convenience init() {
        let client = NetworkGymLogClient.shared
        let workoutReader = client.fetchWorkout
        self.init(workoutReader: workoutReader)
    }
    
    public func execute() -> FutureResult<ObjectDataSource<WorkoutSM>> {
        let readWorkout = self.readWorkout()
            .pipe(into: self.convertToScreenModels(workoutResponse:))
            .pipe(into: self.convertToArray(workout:))
            .pipe(into: self.createArrayObjectDataSource(withScreenModels:))
        return readWorkout
    }
    
    private func convertToScreenModels(workoutResponse: WorkoutResponse) -> FutureResult<WorkoutSM> {
        let deferred = DeferredResult<WorkoutSM>()
        let screenModel = WorkoutSM(
            workoutTitle: workoutResponse.title,
            exercises: workoutResponse.exercises
        )
        deferred.success(value: screenModel)
        return deferred
    }
    
    private func convertToArray(workout: WorkoutSM) -> FutureResult<[WorkoutSM]> {
        let deferred = DeferredResult<[WorkoutSM]>()
        let workoutArray = [workout]
        deferred.success(value: workoutArray)
        return deferred
    }
    
    // TODO: move this to a helper file
    private func createArrayObjectDataSource<T>(withScreenModels models: [T]) -> FutureResult<ObjectDataSource<T>> {
        let deferred = DeferredResult<ObjectDataSource<T>>()
        let dataSource = ArrayObjectDataSource(objects: models)
        deferred.success(value: dataSource)
        return deferred
    }
    
    
}
