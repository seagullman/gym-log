//
//  PostLiftAddViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class PostLiftAddViewController: UIViewController {
    
    public var addExerciseDelegate: AddExerciseDelegate?

    @IBOutlet weak var descriptionTextField: UITextField!
    
    
    @IBAction func savePostLiftExercise(_ sender: Any) {
        let warmUpDescription = self.descriptionTextField.text
        let exerciseSaveModel = ExerciseSaveModel(
            type: .postLift,
            name: warmUpDescription,
            numberOfSets: nil,
            numberOfReps: nil,
            exerciseDescriptions: nil
        )
        
        self.addExerciseDelegate?.exerciseAdded(exercise: exerciseSaveModel)
        performSegue(withIdentifier: "unwindSegueToAddWorkout", sender: self)
    }
    
}
