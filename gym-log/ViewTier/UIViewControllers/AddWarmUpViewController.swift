//
//  AddWarmUpViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class AddWarmUpViewController: UIViewController {
    
    public var addExerciseDelegate: AddExerciseDelegate?

    @IBOutlet weak var addWarmUpTextField: UITextField!
    

    @IBAction func saveWarmUp() {
        let warmUpDescription = self.addWarmUpTextField.text
        let exerciseSaveModel = ExerciseSaveModel(
            type: .warmUp,
            name: warmUpDescription,
            numberOfSets: nil,
            numberOfReps: nil,
            exerciseDescriptions: nil
        )
        
        self.addExerciseDelegate?.exerciseAdded(exercise: exerciseSaveModel)
        performSegue(withIdentifier: "unwindSegueToAddWorkout", sender: self)
    }
}
