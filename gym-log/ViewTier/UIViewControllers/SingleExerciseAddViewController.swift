//
//  SingleExerciseAddViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class SingleExerciseAddViewController: UIViewController {
    
    public var addExerciseDelegate: AddExerciseDelegate?
    
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var setsTextField: UITextField!
    @IBOutlet private weak var repsTextField: UITextField!
    
    
    @IBAction func saveExercise(_ sender: Any) {
        guard
            let description = self.descriptionTextField.text,
            let sets = self.setsTextField.text,
            let reps = self.repsTextField.text
        else { return }
        
        let exercise = ExerciseSaveModel(
            type: .single,
            name: description,
            numberOfSets: Int16(sets),
            numberOfReps: Int16(reps),
            exerciseDescriptions: nil
        )
        
        self.addExerciseDelegate?.exerciseAdded(exercise: exercise)
        self.resignFirstResponder()
        performSegue(withIdentifier: "unwindSegueToAddWorkout", sender: self)
    }
    
}
