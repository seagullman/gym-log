//
//  ViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/6/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import SPRingboard


public class WorkoutDashboardTableViewController: SPRTableViewController {

    override public func loadObjectDataSource() -> FutureResult<ObjectDataSource<Any>> {
        let deferred = DeferredResult<ObjectDataSource<Any>>()
        let command = ReadWorkoutCommand()
        command.execute().then { (result) in
            switch result {
            case .success(let datasource):
                deferred.success(value: datasource.asAny())
            case .failure(let error):
                deferred.failure(error: error)
            }
        }
        return deferred
    }
    
    override public func renderCell(in tableView: UITableView, withModel model: Any, at indexPath: IndexPath) throws -> UITableViewCell {
        NSLog("***** Render cell called")
        let safeCell = self.tableView.dequeueReusableCell(withIdentifier: "workoutDashboardCell", for: indexPath)
        
        guard
            let cell = safeCell as? WorkoutDashboardTableViewCell,
            let screenModel = model as? WorkoutSM
        else { return safeCell }
        
        cell.workoutTitleLabel.text = screenModel.title
        screenModel.exerciseSMs.forEach { (exerciseSM) in
            
            // MARK: Warm Up Exercise
            // The assumption here is that there will be only 1 warm up exercise
            
            if let warmUpSM = exerciseSM as? WarmUpExerciseSM {
                let titleLabel = UILabel()
                titleLabel.font = self.getTitleFont()
                
                let descriptionLabel = UILabel()
                let stackView = UIStackView()
                stackView.axis = .vertical
                
                titleLabel.text = warmUpSM.typeString
                descriptionLabel.text = warmUpSM.name
                
                stackView.addArrangedSubview(titleLabel)
                stackView.addArrangedSubview(descriptionLabel)
                
                cell.stackView.addArrangedSubview(stackView)
            }
            
            // MARK: Single Exercise
            
            if let singleSM = exerciseSM as? SingleExerciseSM {
                let titleLabel = UILabel()
                titleLabel.font = self.getTitleFont()
                
                let descriptionLabel = UILabel()
                let stackView = UIStackView()
                stackView.axis = .vertical
                 
                titleLabel.text = "\(singleSM.numberOfSets)x\(singleSM.numberOfReps)"
                descriptionLabel.text = singleSM.name
                stackView.addArrangedSubview(titleLabel)
                stackView.addArrangedSubview(descriptionLabel)
                
                cell.stackView.addArrangedSubview(stackView)
             }
            
            // MARK: Super Set Exercise
            
            if let superSetSM = exerciseSM as? SuperSetExerciseSM {
                let titleLabel = UILabel()
                titleLabel.font = self.getTitleFont()
                
                let stackView = UIStackView()
                stackView.axis = .vertical
                
                titleLabel.text = "Super Set \(superSetSM.numberOfSets)x\(superSetSM.numberOfReps)"
                stackView.addArrangedSubview(titleLabel)
                
                superSetSM.exerciseDescriptions.forEach { (description) in
                    let descriptionLabel = UILabel()
                    descriptionLabel.text = description
                    stackView.addArrangedSubview(descriptionLabel)
                }
                cell.stackView.addArrangedSubview(stackView)
             }
            
            // MARK: Post Lift Exercise
            
            if let postLiftSM = exerciseSM as? PostLiftExerciseSM {
                let titleLabel = UILabel()
                titleLabel.font = self.getTitleFont()
                
                let descriptionLabel = UILabel()
                let stackView = UIStackView()
                stackView.axis = .vertical
                
                titleLabel.text = postLiftSM.typeString
                descriptionLabel.text = postLiftSM.name
                
                stackView.addArrangedSubview(titleLabel)
                stackView.addArrangedSubview(descriptionLabel)
                cell.stackView.addArrangedSubview(stackView)
            }
        }
        
        return cell
    }
    
    public override func renderCell(in tableView: UITableView, withError error: Error, at indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: Private Functions
    
    private func getTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 16.0)
    }

}

