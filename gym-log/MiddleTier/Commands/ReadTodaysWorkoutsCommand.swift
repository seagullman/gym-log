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
            .pipe(into: convertToWorkoutScreenModels(workouts:))
            .pipe(into: createCustomDataSource(withWorkout:))
        return readWorkout
    }
}
