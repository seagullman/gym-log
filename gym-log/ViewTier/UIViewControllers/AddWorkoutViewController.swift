//
//  AddWorkoutViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/15/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import CoreData

public protocol AddWorkoutDelegate: class {
    func workoutSaved()
}

public protocol AddExerciseDelegate: class {
    func exerciseAdded(exercise: ExerciseSaveModel)
}

public class AddWorkoutViewController: UIViewController, AddExerciseDelegate {
    
    public var delegate: AddWorkoutDelegate?
    public var shouldUseTodaysDate: Bool = false
    
    @IBOutlet weak var exerciseStackView: UIStackView!
    
    @IBAction func navigateToAddExerciseScreen() {
        print("***** Navigating to add exercise screen")
    }
    
    
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        var i = 0
//        while (i < 200) {
//            let label = UILabel()
//            label.text = "Label \(i)"
//            self.stackView.addArrangedSubview(label)
//            i += 1
//        }
//    }
    
    @IBAction func saveWorkout() {
        let managedContext = AppDelegate.viewContext
        let exercises = [
            Exercise.createExercise(context: managedContext, type: .warmUp, name: "5 min Elliptical"),
            Exercise.createExercise(context: managedContext, type: .single, name: "Close Grip Bench Press", numberOfSets: 5, numberOfReps: 5),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 10, exerciseDescriptions: ["Standing EZ Bar Curls", "Skull Crushers"]),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 8, exerciseDescriptions: ["Straight Bar Cable Curls", "Straight Bar Tricep Pushdowns"]),
            Exercise.createExercise(context: managedContext, type: .superSet, name: nil, numberOfSets: 4, numberOfReps: 12, exerciseDescriptions: ["Standing Single Arm Dumbbell Curls", "Overhead Tricep Extensions"]),
            Exercise.createExercise(context: managedContext, type: .postLift, name: "20-25 min swim")
        ]
        
        let _ = Workout.createWorkout(
            context: managedContext,
            workoutTitle: "Wednesday 1/22 - Arms",
            exercises: exercises
        )
        
        self.delegate?.workoutSaved()
        self.presentingViewController?.dismiss(animated: true)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            NSLog("Segue to \(type(of:segue.destination)) missing identifier")
            abort()
        }
        
        switch identifier {
        case "SelectExerciseType":
            guard
                let destination = segue.destination as? ExerciseTypeSelectionViewController
            else { return }
            
            destination.addExerciseDelegate = self
        default:
            NSLog("Unexpected segue identifer: \(identifier)")
            abort()
        }
    }
    
    private func deleteDatabase(_ managedContext: NSManagedObjectContext) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
            print("Deleted")
            
        } catch {
            // Error Handling
        }
    }
    
    // MARK: AddExerciseDelegate
    
    public func exerciseAdded(exercise: ExerciseSaveModel) {
        let view = AddExerciseViewHelper.viewFor(exercise: exercise)
        self.exerciseStackView.addArrangedSubview(view)
    }
    
    @IBAction func unwindToAddWorkout(segue:UIStoryboardSegue) { }

}
