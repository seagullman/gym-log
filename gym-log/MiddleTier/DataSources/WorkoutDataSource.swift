//
//  WorkoutDataSource.swift
//  gym-log
//
//  Created by Brad Siegel on 1/9/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard


public protocol WorkoutDataSourceDelegate: class {
    func showEmptyWorkoutView()
    func hideEmptyWorkoutView()
}

public class WorkoutDataSource: ObjectDataSource<ExerciseSM> {
    
    public let screenModels: [ExerciseSM]
    
    public var delegate: WorkoutDataSourceDelegate?
    private let workout: WorkoutSM?
    
    public init(workoutSM: WorkoutSM? = nil, exercises: [ExerciseSM]) {
        self.workout = workoutSM
        self.screenModels = exercises
    }
    
    // MARK: ObjectDataSource
    
    public override func numberOfObjectsInSection(_ section: Int) -> Int {
        guard section == 0 else { abort() }

        if self.screenModels.count == 0 {
            self.delegate?.showEmptyWorkoutView()
        } else {
            self.delegate?.hideEmptyWorkoutView()
        }

        return self.screenModels.count
    }
    
    public override func numberOfSections() -> Int {
        return 1
    }
    
    public override func objectAt(_ indexPath: IndexPath) throws -> ExerciseSM {
        guard indexPath.section == 0 else { abort() }

        let arrayIndex = indexPath.row
        let screenModel: ExerciseSM
        screenModel = self.screenModels[arrayIndex]
        return screenModel
    }
    
    public override func titleOfSection(_ section: Int) -> String? {
        guard section == 0 else { abort() }
        return self.workout?.title
    }
    
}
