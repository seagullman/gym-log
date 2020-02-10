//
//  AddExerciseIndividualView.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class AddExerciseIndividualView: UIView {

//    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
//        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
    // Public functions
    
    public func layoutView(for exercise: ExerciseSaveModel) {
        switch exercise.type {
        case .warmUp:
            self.layoutWarmUpView(for: exercise)
        case .single:
            self.layoutSingleView(for: exercise)
        case .superSet:
            self.layoutSuperSetView(for: exercise)
        case .postLift:
            self.layoutpostLiftView(for: exercise)
        }
    }
    
    // MARK: Private functions
    
    private func layoutWarmUpView(for warmUpExercise: ExerciseSaveModel) {
        guard let name = warmUpExercise.name else { return }
        
        let typeLabel = UILabel()
        typeLabel.text = "Warm Up"
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = name
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func layoutSingleView(for singleExercise: ExerciseSaveModel) {}
    
    private func layoutSuperSetView(for superSetExercise: ExerciseSaveModel) {}
    
    private func layoutpostLiftView(for postLiftExercise: ExerciseSaveModel) {}
    
    private func setupView() {
        guard let view = self.viewFromNibFor(className: "AddExerciseIndividualView") else { return }
        
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
    }
    
    // MARK: Private Functions
    
    private func viewFromNibFor(className name: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
    
}
