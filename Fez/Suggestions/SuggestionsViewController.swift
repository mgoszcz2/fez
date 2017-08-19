//
//  SuggestionsViewController.swift
//  Warzone
//
//  Created by Maciej Goszczycki on 16/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

// Thank you https://github.com/marcomasser/OverlayTest
private func maskImage(radius: CGFloat) -> NSImage {
    let edgeLength = 2 * radius + 1 // One pixel stripe that isn't an edge inset
    let maskImage = NSImage(size: NSSize(width: edgeLength, height: edgeLength), flipped: false) { rect in
        NSColor.black.set()
        NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
        return true
    }
    maskImage.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
    maskImage.resizingMode = .stretch
    return maskImage
}

public class SuggestionsViewController: NSViewController {
    /// Bind this to an NSTableView in the storyboard
    @IBOutlet public weak var tableView: NSTableView!
    /// Text field which owns this view controller.
    /// Only set after is is returned by the delegate method
    public weak var owningTextField: SuggestingTextField!
    
    private var localEventMonitor: Any?
    private var window: NSWindow?
    private var showItems: [Suggestable] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Do not call super in both. Just not implemented
    public override func moveDown(_ sender: Any?) {
        setSelectedRow(tableView.selectedRow + 1)
    }
    
    public override func moveUp(_ sender: Any?) {
        setSelectedRow(tableView.selectedRow - 1)
    }
    
    private func setSelectedRow(_ ix: Int) {
        if ix < 0 || ix >= tableView.numberOfRows { return }
        tableView.selectRowIndexes([ix], byExtendingSelection: false)
        //FIXME: Slow
        tableView.scrollRowToVisible(tableView.selectedRow)
    }
    
    deinit {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }
}

// Window mgmt
extension SuggestionsViewController {
    func show(_ items: [Suggestable]) {
        showItems = items
        show()
        setSelectedRow(0)
    }
    
    private func processEvent(_ event: NSEvent) {
        // We can click inside this window
        if event.window == window { return }
        
        if event.window == owningTextField.window {
            // Note: Hitting nil should also close window
            let hit = event.window?.hitTest(event)
            if hit != nil && (hit == owningTextField || hit == owningTextField.currentEditor()) {
                show()
            } else {
                close()
            }
        } else {
            close()
        }
    }
    
    func show() {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 20, height: 20),
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: false) // Do not defer
            window.hasShadow = true
            window.backgroundColor = .clear
            window.isOpaque = false
            window.animationBehavior = .utilityWindow
            
            let effect = NSVisualEffectView(frame: NSRect(origin: .zero,
                                                          size: window.frame.size))
            effect.material = .menu
            effect.state = .active
            effect.maskImage = maskImage(radius: 5)
            effect.addSubview(view)
            view.frame = effect.bounds
            view.autoresizingMask = .fill
            
            window.contentView = effect
            self.window = window

            // Close when we select a different app
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(close),
                                                   name: NSWindow.didResignKeyNotification,
                                                   object: owningTextField.window!)
            // Close when we click outside
            let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
            // Weak self important since deinit removes this
            localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
                self?.processEvent(event)
                return event
            }
        }
        
        // Change frame
        tableView.reloadData()
        window!.setFrame(calculateFrame(), display: true)
        
        if !window!.isVisible {
            // For some stupid reason we need to do this here
            // Otherwise it does not register as a child
            // CustomMenus also does it in this order, but fails to mention why
            // Also orderOut removes the child so we don't care ourselves
            owningTextField.window!.addChildWindow(self.window!, ordered: .above)
            window!.orderFront(self)
        }
    }
    
    private func calculateFrame() -> NSRect {
        let lastRow = min(tableView.numberOfRows - 1,
                          owningTextField.suggestionsLimit - 1)
        let lastRowRect = tableView.convert(tableView.rect(ofRow: max(lastRow, 0)), to: view)
        let height: CGFloat = view.bounds.height - lastRowRect.minY
        var frame = owningTextField.screenFrame
            .offsetBy(dx: 0, dy: -height - 3)
        frame.size.height = height
        return frame
    }
    
    // Called by SuggestingTextField also
    @objc func close() {
        window?.orderOut(self)
    }
}

extension SuggestionsViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
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
