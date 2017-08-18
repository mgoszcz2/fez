//
//  WindowExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 18/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSWindow {
    /// Test which view the event hit
    func hitTest(_ event: NSEvent) -> NSView? {
        guard let content = contentView else { return nil }
        let viewLocation = content.convert(event.locationInWindow, from: nil)
        return content.hitTest(viewLocation)
    }
}
