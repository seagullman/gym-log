//
//  EmptyWorkoutView.swift
//  gym-log
//
//  Created by Brad Siegel on 1/9/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public protocol EmptyWorkoutViewDelegate: class {
    func addWorkout()
}

public class EmptyWorkoutView: UIView {
    
    public var delegate: EmptyWorkoutViewDelegate?

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
        guard let view = self.viewFromNibFor(className: "EmptyWorkoutView") else { return }
        
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
    }
    
    @IBAction func addWorkout() {
        self.delegate?.addWorkout()
    }
    
    // MARK: Private Functions
    
    private func viewFromNibFor(className name: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }
    

}
