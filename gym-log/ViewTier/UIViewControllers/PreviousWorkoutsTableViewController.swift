//
//  PreviousWorkoutsTableViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/22/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import SPRingboard


public class PreviousWorkoutsTableViewController: SPRTableViewController {

    public override func loadObjectDataSource() -> FutureResult<ObjectDataSource<Any>> {
        let deferred = DeferredResult<ObjectDataSource<Any>>()
        let command = ReadPreviousWorkoutsCommand()
        command.execute().then { (result) in
            switch result {
            case .success(let dataSource):
                deferred.success(value: dataSource.asAny())
            case .failure(let error):
                deferred.failure(error: error)
            }
        }
        return deferred
    }
    
    override public func renderCell(in tableView: UITableView, withModel model: Any, at indexPath: IndexPath) throws -> UITableViewCell {
        let safeCell = self.tableView.dequeueReusableCell(withIdentifier: "previousWorkoutCell", for: indexPath)
        
        guard
            let cell = safeCell as? SimpleExerciseTableViewCell,
            let screenModel = model as? WorkoutSM
        else { return safeCell }
        
        cell.workoutTitleLabel.text = screenModel.title
        cell.workoutDateLabel.text = screenModel.date
        
        return cell
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            NSLog("Segue to \(type(of:segue.destination)) missing identifier")
            abort()
        }
        
        switch identifier {
        case "showWorkoutDetails":
            guard
                let destination = segue.destination as? WorkoutDetailsTableViewController,
                let indexPath = self.tableView.indexPathForSelectedRow,
                let selectedViewModel: WorkoutSM = try? objectDataSource.objectAt(indexPath) as? WorkoutSM,
                let lookupKey = selectedViewModel.lookupKey
            else { return }
            
            print("PREPARE FOR SEGUE --> setting lookupKey: \(lookupKey)")
            destination.lookupKey = lookupKey
        default:
            NSLog("Unexpected segue identifer: \(identifier)")
            abort()
        }
    }

}
