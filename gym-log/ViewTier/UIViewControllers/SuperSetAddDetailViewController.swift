//
//  SuperSetAddDetailViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 2/10/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit

public protocol AddSuperSetDelegate: class {
    func exerciseDescriptionAdded(description: String)
}

public class SuperSetAddDetailViewController: UIViewController {

    public var delegate: AddSuperSetDelegate?
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet private weak var superSetDescriptionTextField: UITextField!
    
    
    @IBAction func saveDescription(_ sender: Any) {
        guard let description = self.superSetDescriptionTextField.text else { return }
        
        self.delegate?.exerciseDescriptionAdded(description: description)
        self.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
}
