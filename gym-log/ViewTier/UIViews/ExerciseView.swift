//
//  ExerciseView.swift
//  gym-log
//
//  Created by Brad Siegel on 1/20/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit
import M13Checkbox

public protocol ExerciseViewDelegate: class {
    func didToggleExercise(withValue checked: Bool, exerciseSM: ExerciseSM)
}

@IBDesignable
public class ExerciseView: UIView {
    
    @IBOutlet private weak var exerciseStackView: UIStackView!
    @IBOutlet private weak var checkbox: M13Checkbox!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var exerciseDescriptionLabels: [UILabel] = []
    
    public var delegate: ExerciseViewDelegate?
    public var exercise: ExerciseSM? {
        didSet {
            guard let _exercise = exercise else { return }
            
            self.exerciseDescriptionLabels = []
            self.layoutViews(with: _exercise)
        }
    }

    @IBAction func toggleExerciseCompleted(_ sender: Any) {
        guard let exercise = self.exercise else { return }
        
        let checked = self.checkbox.checkState == .checked
        self.delegate?.didToggleExercise(withValue: checked, exerciseSM: exercise)
        
        if (checked) {
            self.nameLabel.textColor = UIColor.systemGray
            self.descriptionLabel.textColor = UIColor.systemGray
            
            self.exerciseDescriptionLabels.forEach { $0.textColor = UIColor.systemGray }
        } else {
            self.nameLabel.textColor = UIColor.label
            self.descriptionLabel.textColor = UIColor.label
            
            self.exerciseDescriptionLabels.forEach { $0.textColor = UIColor.label }
        }
    }
    
    // MARK: Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: Private functions
    
    private func setupView() {
        guard let view = self.viewFromNibFor(className: "ExerciseView") else { return }
        
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
    }
    
    private func layoutViews(with exerciseSM: ExerciseSM) {
        self.checkbox.checkState = exerciseSM.completed ? .checked : .unchecked
        
        if let warmUpSM = exerciseSM as? WarmUpExerciseSM {
            self.nameLabel.font = self.getTitleFont()
            let stackView = UIStackView()
            stackView.axis = .vertical
            
            if (exerciseSM.completed) {
                self.nameLabel.textColor = UIColor.systemGray
                self.descriptionLabel.textColor = UIColor.systemGray
            }

            self.nameLabel.text = warmUpSM.typeString
            self.descriptionLabel.text = warmUpSM.name

            stackView.addArrangedSubview(self.nameLabel)
            stackView.addArrangedSubview(self.descriptionLabel)

            self.exerciseStackView.addArrangedSubview(stackView)
        }
        
        // MARK: Single Exercise
        
        if let singleSM = exerciseSM as? SingleExerciseSM {
            self.nameLabel.font = self.getTitleFont()

            let stackView = UIStackView()
            stackView.axis = .vertical
            
            if (exerciseSM.completed) {
                self.nameLabel.textColor = UIColor.systemGray
                self.descriptionLabel.textColor = UIColor.systemGray
            }

            self.nameLabel.text = "\(singleSM.numberOfSets)x\(singleSM.numberOfReps)" // TODO: move this text formatting to screenmodel
            self.descriptionLabel.text = singleSM.name
            stackView.addArrangedSubview(self.nameLabel)
            stackView.addArrangedSubview(descriptionLabel)

            self.exerciseStackView.addArrangedSubview(stackView)
         }
        
        // MARK: Super Set Exercise
        
        if let superSetSM = exerciseSM as? SuperSetExerciseSM {
            self.nameLabel.font = self.getTitleFont()
            
            let stackView = UIStackView()
            stackView.axis = .vertical
            
            if (exerciseSM.completed) {
                self.nameLabel.textColor = UIColor.systemGray
            }
            
            self.nameLabel.text = "Super Set \(superSetSM.numberOfSets)x\(superSetSM.numberOfReps)"
            stackView.addArrangedSubview(self.nameLabel)
            
            superSetSM.exerciseDescriptions.forEach { (description) in
                let descriptionLabel = UILabel()
                self.exerciseDescriptionLabels.append(descriptionLabel)
                descriptionLabel.text = description
                if (exerciseSM.completed) {
                    descriptionLabel.textColor = UIColor.systemGray
                }
                stackView.addArrangedSubview(descriptionLabel)
            }
            self.exerciseStackView.addArrangedSubview(stackView)
         }
        
        // MARK: Post Lift Exercise
        
        if let postLiftSM = exerciseSM as? PostLiftExerciseSM {
            self.nameLabel.font = self.getTitleFont()

            let stackView = UIStackView()
            stackView.axis = .vertical

            if (exerciseSM.completed) {
                self.nameLabel.textColor = UIColor.systemGray
                self.descriptionLabel.textColor = UIColor.systemGray
            }
            
            self.nameLabel.text = postLiftSM.typeString
            self.descriptionLabel.text = postLiftSM.name

            stackView.addArrangedSubview(self.nameLabel)
            stackView.addArrangedSubview(self.descriptionLabel)
            self.exerciseStackView.addArrangedSubview(stackView)
        }
    }
    
    // MARK: Private Functions
    
    private func viewFromNibFor(className name: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
    
    // MARK: Private Functions
    
    private func getTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 16.0)
    }

}
