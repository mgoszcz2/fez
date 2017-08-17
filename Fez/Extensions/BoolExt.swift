//
//  BoolExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension Bool {
    /// This bool represented as a menu state
    var menuState: NSControl.StateValue {
        return self ? .on : .off
    }
}
