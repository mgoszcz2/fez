//
//  MenuExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

public extension NSMenu {
    /// Item with a given idenitfier
    func item(with identifier: NSUserInterfaceItemIdentifier) -> NSMenuItem? {
        for item in items {
            if item.identifier == identifier {
                return item
            }
        }
        return nil
    }
    
    /// Add multiple menu items
    func addItems(_ items: [NSMenuItem]) {
        items.forEach { addItem($0) }
    }
    
    /// Remove all items after a given index
    func removeItemsAfter(item: NSMenuItem) {
        let ix = index(of: item)
        if ix < 0 { return }
        for ix in (ix + 1..<numberOfItems).reversed() {
            removeItem(at: ix)
        }
    }
}
