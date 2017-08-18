//
//  SuggestionsViewController.swift
//  Warzone
//
//  Created by Maciej Goszczycki on 16/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

public class SuggestionsViewController: NSViewController {
    /// Bind this to an NSTableView in the storyboard
    @IBOutlet public weak var tableView: NSTableView!
    /// Text field which owns this view controller.
    /// Only set after is is returned by the delegate method
    public var owningTextField: SuggestingTextField!
    
    private var localEventMonitor: Any?
    private weak var window: NSWindow?
    private var showItems: [Suggestable] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Do not call super in both. Just not implemented
    public override func moveDown(_ sender: Any?) {
        tableView.selectRowIndexes([tableView.selectedRow + 1], byExtendingSelection: false)
        NSAnimationContext.withDuration(0) {
            tableView.scrollRowToVisible(tableView.selectedRow)
        }
    }
    
    public override func moveUp(_ sender: Any?) {
        tableView.selectRowIndexes([tableView.selectedRow - 1], byExtendingSelection: false)
        NSAnimationContext.withDuration(0) {
            tableView.scrollRowToVisible(tableView.selectedRow)
        }
    }
}

// Window mgmt
extension SuggestionsViewController {
    func show(_ items: [Suggestable]) {
        showItems = items
        show()
    }
    
    private func processEvent(_ event: NSEvent) {
        // We can click inside this window
        if event.window == self.window { return }
        
        if event.window == self.owningTextField.window {
            // Do not if we clicked inside text field
            let hit = event.window?.hitTest(event)
            if hit != self.owningTextField && hit != self.owningTextField.currentEditor() {
                self.window?.close()
            } else {
                self.show()
            }
        } else {
            self.window?.close()
        }
    }
    
    private func show() {
        if window == nil {
            let window = NSWindow(contentViewController: self)
            window.styleMask = [.borderless]
            window.hasShadow = true
            self.window = window
            owningTextField.window!.addChildWindow(window, ordered: .above)
            
            // Close when we select a different app
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(close),
                                                   name: NSWindow.didResignKeyNotification,
                                                   object: owningTextField.window!)
            // Close when we click outside
            let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
            localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
                self.processEvent(event)
                return event
            }
        }
        
        // Change frame
        tableView.reloadData()
        let lastRow = min(tableView.numberOfRows - 1,
                          owningTextField.suggestionDelegate!.suggestionLimit(owningTextField) - 1)
        let lastRowRect = tableView.convert(tableView.rect(ofRow: max(lastRow, 0)), to: view)
        let height: CGFloat = view.bounds.height - lastRowRect.minY
        var frame = owningTextField.screenFrame
            .offsetBy(dx: 0, dy: -height - 3)
        frame.size.height = height
        window!.setFrame(frame,
                         display: true)
        
        if !window!.isVisible {
            window!.orderFront(self)
        }
    }
    
    // Called by SuggestingTextField also
    @objc func close() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        window?.close()
    }
}

extension SuggestionsViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //FIXME: Neccesary?
//        if showItems.count <= row { return nil }
        return owningTextField.suggestionDelegate?.viewFor(tableView, item: showItems[row])
    }
}

extension SuggestionsViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return showItems.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return showItems[row]
    }
}
