//
//  WorkoutDetailsDataSource.swift
//  gym-log
//
//  Created by Brad Siegel on 1/23/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import SPRingboard

public protocol WorkoutDetailsDataSourceDelegate: class {
    func showEmptyWorkoutView()
    func hideEmptyWorkoutView()
}

public class WorkoutDetailsDataSource: ObjectDataSource<WorkoutSM> {
    
    private var screenModels: [WorkoutSM] = []
    public var delegate: WorkoutDetailsDataSourceDelegate?
    
    public init(workoutSM: WorkoutScreenModel?) {
        if let workout = workoutSM,
           let _workout = workout as? WorkoutSM {
            self.screenModels = [_workout]
        }
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
    
    public override func objectAt(_ indexPath: IndexPath) throws -> WorkoutSM {
        guard indexPath.section == 0 else { abort() }

        let arrayIndex = indexPath.row
        let screenModel: WorkoutSM
        screenModel = self.screenModels[arrayIndex]
        return screenModel
    }
    
    public override func titleOfSection(_ section: Int) -> String? {
        guard section == 0 else { abort() }
        return nil
    }
    
}
