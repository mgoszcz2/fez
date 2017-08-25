//
//  DataExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 24/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

// Courtesy of https://stackoverflow.com/questions/38023838
public extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
