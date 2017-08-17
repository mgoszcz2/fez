//
//  AnimationContextExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSAnimationContext {
    /// Run the block with custom interval
    class func withDuration(_ interval: TimeInterval, block: () -> ()) {
        NSAnimationContext.runAnimationGroup({ctx in
            ctx.duration = interval
            block()
        }, completionHandler: nil)
    }
}
