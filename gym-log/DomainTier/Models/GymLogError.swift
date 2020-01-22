//
//  GymLogError.swift
//  gym-log
//
//  Created by Brad Siegel on 1/15/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import UIKit

public enum GymLogError: Error {
    case databaseReadError(message: String)
    case updateError(message: String)
    case missingValueForPropertyError(message: String)
}
