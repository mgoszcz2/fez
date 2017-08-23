//
//  FadeInWindow.swift
//  Fez
//
//  Created by Maciej Goszczycki on 23/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

private let FadeInterval: TimeInterval = 0.13
private let ScaleStart: CGFloat = 0.96

open class FadeInWindow: NSWindow {
    private lazy var link = DisplayLink(target: self, selector: #selector(updateAnimation(_:)))
    private var animating = false
    
    open func orderFrontAnimating(sender: Any?) {
        super.orderFront(sender)
        if animating { return }
        if !occlusionState.contains(.visible) {
            scale(to: ScaleStart)
            alphaValue = 0
            link.start()
        }
    }

    @objc private func updateAnimation(_ time: NSNumber) {
        let interval = time.doubleValue
        if interval > FadeInterval {
            link.stop()
            scale(to: 1)
            alphaValue = 1
            animating = false
        } else {
            let easeOut = pow(CGFloat(interval / FadeInterval) - 1, 3) + 1.0
            self.scale(to: ScaleStart + (1 - ScaleStart) * easeOut)
            self.alphaValue = CGFloat(interval / FadeInterval)
        }
    }
}
