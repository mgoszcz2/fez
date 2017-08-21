//
//  TrackingRowView.swift
//  Fez
//
//  Created by Maciej Goszczycki on 21/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

class TrackingRowView: NSTableRowView {
    private var trackingArea: NSTrackingArea?
    weak var owningSuggestionsController: SuggestionsViewController!
    
    override func mouseEntered(with event: NSEvent?) {
        if owningSuggestionsController.shouldIgnoreMouseEnterEvent {
           return
        }
        
        if let ev = event { super.mouseEntered(with: ev) }
        let table = superview as! NSTableView
        table.selectRowIndexes([table.row(for: self)], byExtendingSelection: false)
    }
    
    override func mouseMoved(with event: NSEvent) {
        if isSelected {
            return
        }
        super.mouseMoved(with: event)
        mouseEntered(with: nil)
    }
    
    // Big thanks to https://stackoverflow.com/questions/8979639/
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea {
            removeTrackingArea(area)
        }
        trackingArea = NSTrackingArea(rect: bounds,
                                      options: [.mouseEnteredAndExited, .mouseMoved, .activeInActiveApp],
                                      owner: self,
                                      userInfo: nil)
        addTrackingArea(trackingArea!)
        
        // This is to make it work soon after scroll
        if bounds.contains(convert(window!.mouseLocationOutsideOfEventStream, from: nil)) {
            mouseEntered(with: nil)
        }
    }
}
