//
//  ExerciseTypeSelectionViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class ExerciseTypeSelectionViewController: UIViewController {

    public var addExerciseDelegate: AddExerciseDelegate?
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            NSLog("Segue to \(type(of:segue.destination)) missing identifier")
            abort()
        }
        
        switch identifier {
        case "AddWarmUp":
            guard
                let destination = segue.destination as? AddWarmUpViewController
            else { return }
            
            destination.addExerciseDelegate = self.addExerciseDelegate
        default:
            NSLog("Unexpected segue identifer: \(identifier)")
            abort()
        }
    }

}
