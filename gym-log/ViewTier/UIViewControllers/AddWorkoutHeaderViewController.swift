//
//  AddWorkoutHeaderViewController.swift
//  gym-log
//
//  Created by Brad Siegel on 1/27/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit


public class AddWorkoutHeaderViewController: UIViewController {

    @IBOutlet weak var workoutDateTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.datePicker = UIDatePicker()
        self.datePicker?.datePickerMode = .date
        self.datePicker?.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        
        self.workoutDateTextField.inputView = self.datePicker
        
        //Create UIToolbar that displays 'Done' button
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(dismissKeyboard))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
//        toolBar.setItems([flexButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.workoutDateTextField.inputAccessoryView = toolBar
        
        toolBar.sizeToFit()
    }
    
    // MARK: Private functions
    
    @objc private func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.workoutDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
