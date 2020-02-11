//
//  ViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/6/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import SPRingboard


public class WorkoutDashboardTableViewController: SPRTableViewController,
                                                  WorkoutDataSourceDelegate,
                                                  EmptyWorkoutViewDelegate,
                                                  AddWorkoutDelegate,
                                                  ExerciseViewDelegate {
    
    private var emptyWorkoutView: EmptyWorkoutView?
    private final let sectionHeaderHeight: CGFloat = 50
    
    // MARK: Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let emptyWorkoutView = EmptyWorkoutView()
        emptyWorkoutView.delegate = self
        emptyWorkoutView.isHidden = true
        
        self.emptyWorkoutView = emptyWorkoutView
        self.tableView.backgroundView = self.emptyWorkoutView
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            NSLog("Segue to \(type(of:segue.destination)) missing identifier")
            abort()
        }
        
        switch identifier {
        case "AddNewWorkout":
            guard
                let destination = segue.destination as? AddWorkoutViewController
            else { return }
            
            destination.delegate = self
        default:
            NSLog("Unexpected segue identifer: \(identifier)")
            abort()
        }
    }
    
    override public func loadObjectDataSource() -> FutureResult<ObjectDataSource<Any>> {
        let deferred = DeferredResult<ObjectDataSource<Any>>()
        let command = ReadTodaysWorkoutsCommand()
        command.execute().then { (result) in
            switch result {
            case .success(let datasource):
                datasource.delegate = self
                deferred.success(value: datasource.asAny())
            case .failure(let error):
                deferred.failure(error: error)
            }
        }
        return deferred
    }
    
    override public func renderCell(in tableView: UITableView, withModel model: Any, at indexPath: IndexPath) throws -> UITableViewCell {
        let safeCell = self.tableView.dequeueReusableCell(withIdentifier: "workoutDashboardCell", for: indexPath)
        
        guard
            let cell = safeCell as? WorkoutDashboardTableViewCell,
            let screenModel = model as? ExerciseSM
        else { return safeCell }
        
        let exerciseView = ExerciseView()
        exerciseView.exercise = screenModel
        exerciseView.delegate = self
        cell.stackView.addArrangedSubview(exerciseView)
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sectionHeaderHeight
    }
    
    public override func renderCell(in tableView: UITableView, withError error: Error, at indexPath: IndexPath) -> UITableViewCell {
        // TODO: implement
        return UITableViewCell()
    }
    
    override public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
            header.contentView.backgroundColor = .secondarySystemBackground
        }
    }
    
    // MARK: WorkoutDataSourceDelegate
    
    public func showEmptyWorkoutView() {
        self.tableView.isScrollEnabled = false
        self.emptyWorkoutView?.isHidden = false
    }
    
    public func hideEmptyWorkoutView() {
        self.tableView.isScrollEnabled = true
        self.emptyWorkoutView?.isHidden = true
    }
    
    // MARK: AddWorkoutDelegate
    
    public func workoutSaved() {
        self.setNeedsModelLoaded()
    }
    
    // MARK: EmptyWorkoutViewDelegate
    
    public func addWorkout() {
        performSegue(withIdentifier: "AddNewWorkout", sender: nil)
    }
    
    // MARK: ExerciseViewDelegate
    
    public func didToggleExercise(withValue checked: Bool, exerciseSM: ExerciseSM) {
        let updateCommand = UpdateExerciseCommand()
        updateCommand.completed = checked
        updateCommand.exercise = exerciseSM.managedObject
        updateCommand.execute().then { (result) in
            switch result {
            case .success(_):
                NSLog("***** Updated exercise successfully")
            case .failure(let error):
                NSLog("***** ERROR: Failed to update exercise: \(error)")
            }
        }
    }
    
    // MARK: Private Functions
    
    private func getTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 16.0)
    }

}

