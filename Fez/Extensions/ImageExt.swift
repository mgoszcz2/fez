//
//  ImageExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSImage {
    /// Aspect ratio (`width / height`) of the image
    var aspectRatio: Double {
        return Double(size.width) / Double(size.height)
    }
    
    /// Save the image ta a given format
    func saveTo(_ url: URL, using format: NSBitmapImageRep.FileType) -> Bool {
        guard let tiffData = tiffRepresentation else { return false }
        let imageRep = NSBitmapImageRep(data: tiffData)
        try! imageRep?.representation(using: format, properties: [:])?.write(to: url)
        return true
    }
    
    /// Tint the image with a color
    func tinted(_ color: NSColor) -> NSImage {
        let tinted = self.copy() as! NSImage
        tinted.isTemplate = false
        tinted.lockFocus()
        color.set()
        NSRect(origin: .zero, size: size).fill(using: .sourceAtop)
        tinted.unlockFocus()
        return tinted
    }
}
