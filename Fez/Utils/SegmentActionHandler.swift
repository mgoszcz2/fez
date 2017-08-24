//
//  SegmentActionHandler.swift
//  Fez
//
//  Created by Maciej Goszczycki on 18/07/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

// Allows us to have a weak ref to target
private class TargetActionStore {
    unowned var target: NSObject
    let action: Selector
    init(_ target: NSObject, _ action: Selector) {
        self.target = target
        self.action = action
    }
}

// NSObject allows us to put it in IB
/// Simplify triggering functions using segmented controls
public class SegmentActionHandler: NSObject {
    @IBOutlet public var segmentControl: NSSegmentedControl? {
        didSet {
            segmentControl?.action = #selector(segmentClicked(_:))
            segmentControl?.target = self
        }
    }
    private var actions = [Int: TargetActionStore]()
    
    @objc private func segmentClicked(_ sender: NSSegmentedControl) {
        if let store = actions[sender.selectedSegment] {
            let _ = store.target.perform(store.action, with: sender)
        } else {
            print("Fez unknown action for segment \(sender.selectedSegment)")
        }
    }
    
    /// Register a selector to perform if a segment with the index is clicked
    public func index(_ ix: Int, target: NSObject, action: Selector) {
        actions[ix] = TargetActionStore(target, action)
    }
}

