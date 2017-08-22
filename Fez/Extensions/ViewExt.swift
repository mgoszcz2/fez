//
//  ViewExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSView.AutoresizingMask {
    public static let fill: NSView.AutoresizingMask = [.minXMargin,
                                                       .maxXMargin,
                                                       .minYMargin,
                                                       .maxYMargin,
                                                       .width,
                                                       .height]
}

public extension NSView {
    /// Frame of the view on screen
    var screenFrame: NSRect {
        return window!.convertToScreen(convert(bounds, to: nil))
    }
    
    /// Get a view with identifier
    func viewWith(identifier: NSUserInterfaceItemIdentifier) -> NSView? {
        for view in subviews {
            if view.identifier == identifier {
                return view
            }
            if let subview = view.viewWith(identifier: identifier) {
                return subview
            }
        }
        return nil
    }
    
    func edges(to otherView: NSView) {
        otherView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: otherView.topAnchor),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor),
            leftAnchor.constraint(equalTo: otherView.leftAnchor),
            rightAnchor.constraint(equalTo: otherView.rightAnchor)
        ])
    }
}
