//
//  SuperSetAddMasterViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class SuperSetAddMasterViewController: UIViewController, AddSuperSetDelegate {
    
    @IBOutlet private weak var exerciseDescriptionsStackView: UIStackView!
    @IBOutlet private weak var setsTextField: UITextField!
    @IBOutlet private weak var repsTextField: UITextField!
    
    public var addExerciseDelegate: AddExerciseDelegate?
    
    private var descriptions: [String] = []
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            NSLog("Segue to \(type(of:segue.destination)) missing identifier")
            abort()
        }
        
        switch identifier {
        case "AddSuperSetDescription":
            guard
                let destination = segue.destination as? SuperSetAddDetailViewController
            else { return }
            
            destination.delegate = self
        case "unwindSegueToAddWorkout":
            break
        default:
            NSLog("Unexpected segue identifer: \(identifier)")
            abort()
        }
    }
    
    // MARK: AddSuperSetDelegate
    
    public func exerciseDescriptionAdded(description: String) {
        self.descriptions.append(description)
        let label = UILabel()
        label.text = description
        
        self.exerciseDescriptionsStackView.addArrangedSubview(label)
    }
    
    @IBAction func saveSuperSet() {
        guard
            let sets = self.setsTextField.text,
            let reps = self.repsTextField.text
        else { return }
        
        let exercise = ExerciseSaveModel(
            type: .superSet,
            name: nil,
            numberOfSets: Int16(sets),
            numberOfReps: Int16(reps),
            exerciseDescriptions: self.descriptions
        )
        
        self.addExerciseDelegate?.exerciseAdded(exercise: exercise)
        performSegue(withIdentifier: "unwindSegueToAddWorkout", sender: self)
    }

}
