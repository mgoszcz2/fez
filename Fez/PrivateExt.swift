//
//  PrivateExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 23/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

@objc fileprivate protocol _NSWindowPrivate {
    func _setTransformForAnimation(_: CGAffineTransform, anchorPoint: CGPoint)
}

public extension NSWindow {
    // Thanks to https://github.com/avaidyam/Parrot/blob/master/MochaUI/AppKit%2BExtensions.swift
    public func scale(to scale: CGFloat, anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        let realAnchor = CGPoint(x: anchorPoint.x * frame.size.width,
                                 y: anchorPoint.y * frame.size.height)
        // Apply the transformation by transparently using CGSSetWindowTransformAtPlacement()
        let transform = CGAffineTransform(scaleX: 1.0 / scale, y: 1.0 / scale)
        unsafeBitCast(self, to: _NSWindowPrivate.self)
            ._setTransformForAnimation(transform, anchorPoint: realAnchor)
    }
}
