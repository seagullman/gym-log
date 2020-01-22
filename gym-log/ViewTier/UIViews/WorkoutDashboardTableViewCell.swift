//
//  WorkoutDashboardTableViewCell.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit

public class WorkoutDashboardTableViewCell: UITableViewCell {
    @IBOutlet weak var stackView: UIStackView!
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        _ = self.stackView.arrangedSubviews.map { self.stackView.removeArrangedSubview($0) }
    }
}
