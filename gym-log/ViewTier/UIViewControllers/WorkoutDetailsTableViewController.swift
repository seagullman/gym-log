//
//  WorkoutDetailsTableViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/23/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import SPRingboard


public class WorkoutDetailsTableViewController: SPRTableViewController,
                                                WorkoutDetailsDataSourceDelegate
{
    
    public var lookupKey: UUID?

    public override func loadObjectDataSource() -> FutureResult<ObjectDataSource<Any>> {
        guard let id = self.lookupKey else {
            NSLog("***** ERROR: WorkoutDetailsTableViewController --> lookupKey not set")
            abort()
        }
        
        let deferred = DeferredResult<ObjectDataSource<Any>>()
        let command = ReadWorkoutDetailsCommand()
        command.lookupKey = id
        command.execute().then { (result) in
            switch result {
            case .success(let dataSource):
                dataSource.delegate = self
                deferred.success(value: dataSource.asAny())
            case .failure(let error):
                deferred.failure(error: error)
            }
        }
        return deferred
    }
    
    public override func renderCell(in tableView: UITableView, withModel model: Any, at indexPath: IndexPath) throws -> UITableViewCell {
        let safeCell = self.tableView.dequeueReusableCell(withIdentifier: "workoutDetailsCell", for: indexPath)
        
        guard
            let cell = safeCell as? WorkoutDetailsTableViewCell,
            let screenModel = model as? WorkoutSM
        else { return safeCell }
        
        cell.workoutDetailsTestLabel.text = screenModel.title
        
        return cell
    }
    
    // MARK: WorkoutDetailsDataSourceDelegate
    
    public func showEmptyWorkoutView() {
        
    }
    
    public func hideEmptyWorkoutView() {
        
    }

}
