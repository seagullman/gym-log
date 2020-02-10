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
    
    public class func viewForWarmUp(exercise: ExerciseSaveModel) -> UIView {
        let descriptionLabel = self.getFormattedExerciseDescriptionLabel()
        descriptionLabel.text = exercise.name
        
        let typeLabel = self.getFormattedExerciseTypeLabel()
        typeLabel.text = "Warm Up"
        
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
