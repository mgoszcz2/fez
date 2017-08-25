//
//  TintedImageView.swift
//  Fez
//
//  Created by Maciej Goszczycki on 24/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

@IBDesignable
public class TintedImageView: NSView {
    @IBInspectable public var tintColor: NSColor = .labelColor { didSet { needsDisplay = true } }
    @IBInspectable public var image: NSImage? { didSet { needsDisplay = true } }
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        image?.tinted(tintColor).draw(in: bounds)
    }
}
