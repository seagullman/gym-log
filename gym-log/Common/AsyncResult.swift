//
//  AsyncResult.swift
//  gym-log
//
//  Created by Brad Siegel on 1/7/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation

public enum AsyncResult<T> {
    case success(T)
    case failure(Error)
}
