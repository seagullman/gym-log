//
//  AddExerciseViewHelper.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import UIKit


public class AddExerciseViewHelper {
    
    // TODO: format labels
    
    public class func viewFor(exercise: ExerciseSaveModel) -> UIView {
        let descriptionLabel = self.getFormattedExerciseDescriptionLabel()
        descriptionLabel.text = exercise.name
        
        let typeText: String
        switch exercise.type {
        case .warmUp:
            typeText = "Warm Up"
        case .single:
            typeText = "Single"
        case .superSet:
            typeText = "Super Set"
        case .postLift:
            typeText = "Post-lift"
        }
        
        let typeLabel = self.getFormattedExerciseTypeLabel()
        typeLabel.text = typeText
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(typeLabel)
        
        return stackView
    }
    
    public class func viewForSuperSet(exercise: ExerciseSaveModel) -> UIView {
        let descriptionLabel = self.getFormattedExerciseDescriptionLabel()
        var descriptionText = ""
        exercise.exerciseDescriptions?.forEach({ (description) in
            let index = exercise.exerciseDescriptions?.firstIndex(of: description)
            descriptionText.append(description)
            
            if (index! < (exercise.exerciseDescriptions!.count - 1)) {
                descriptionText.append(contentsOf: ",")
            }
        })
        descriptionLabel.text = descriptionText
        
        let typeText = "Super Set"
        
        let typeLabel = self.getFormattedExerciseTypeLabel()
        typeLabel.text = typeText
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(typeLabel)
        
        return stackView
    }
    
    private class func getFormattedExerciseTypeLabel() -> UILabel {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 15, weight: .thin)
        label.font = font
        label.textColor = UIColor.systemGray
        return label
    }
    
    private class func getFormattedExerciseDescriptionLabel() -> UILabel {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 15, weight: .thin)
        label.font = font
        return label
    }
}
