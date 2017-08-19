//
//  SuggestionsViewController.swift
//  Warzone
//
//  Created by Maciej Goszczycki on 16/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

private let cornerRadius: CGFloat = 5

// Thank you https://github.com/marcomasser/OverlayTest
private func maskImage(radius: CGFloat) -> NSImage {
    let edgeLength = 2 * radius + 1 // One pixel stripe that isn't an edge inset
    let maskSize = NSSize(width: edgeLength, height: edgeLength)
    let maskImage = NSImage(size: maskSize, flipped: false) { rect in
        NSColor.black.set()
        NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
        return true
    }
    maskImage.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
    maskImage.resizingMode = .stretch
    return maskImage
}

open class SuggestionsViewController: NSViewController {
    /// Bind this to an NSTableView in the storyboard
    @IBOutlet open weak var tableView: NSTableView!
    /// Text field which owns this view controller.
    /// Only set after is is returned by the delegate method
    public internal(set) weak var owningTextField: SuggestingTextField!
    
    private var localEventMonitor: Any?
    private var window: NSWindow?
    private var shownItems: [Suggestable] = []
    weak var selectedItem: Suggestable?

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Do not call super in both. Just not implemented
    open override func moveDown(_ sender: Any?) {
        setSelectedRow(tableView.selectedRow + 1)
    }
    
    open override func moveUp(_ sender: Any?) {
        setSelectedRow(tableView.selectedRow - 1)
    }
    
    private func setSelectedRow(_ ix: Int) {
        if ix < 0 || ix >= tableView.numberOfRows { return }
        selectedItem = shownItems[ix]
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
        shownItems = items
        show()
        setSelectedRow(0)
        tableView.enclosingScrollView!.flashScrollers()
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
    
    private func show() {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 20, height: 20),
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: false) // Do not defer
            window.hasShadow = true
            window.backgroundColor = .clear
            window.isOpaque = false
            
            let effect = NSVisualEffectView(frame: NSRect(origin: .zero,
                                                          size: window.frame.size))
            effect.material = .menu
            effect.state = .active
            effect.maskImage = maskImage(radius: cornerRadius)
            effect.addSubview(view)
            
            // Zero margin
            view.translatesAutoresizingMaskIntoConstraints = false
            effect.addConstraints([view.topAnchor.constraint(equalTo: effect.topAnchor),
                                   view.bottomAnchor.constraint(equalTo: effect.bottomAnchor),
                                   view.leftAnchor.constraint(equalTo: effect.leftAnchor),
                                   view.rightAnchor.constraint(equalTo: effect.rightAnchor)])
            
            window.contentView = effect
            self.window = window
            
            // Table view is loaded now
            let scrollView = tableView.enclosingScrollView!
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsets(top: cornerRadius,
                                                    left: 0,
                                                    bottom: cornerRadius,
                                                    right: 0)
            scrollView.verticalScrollElasticity = .none
            scrollView.drawsBackground = false
            scrollView.borderType = .noBorder
            tableView.backgroundColor = .clear
            tableView.selectionHighlightStyle = .regular
            tableView.allowsTypeSelect = false
            tableView.allowsEmptySelection = false
            tableView.allowsMultipleSelection = false
            tableView.headerView = nil

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
        if tableView.numberOfRows == 0 {
            close()
            return
        }
        
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
        // No need to convert since in scroll view
        let lastRowRect = tableView.rect(ofRow: max(lastRow, 0))
        
        // Table view is flipped by default it seems
        // Do not forget about content insets for corners
        let rowBottom = lastRowRect.height + lastRowRect.minY + cornerRadius * 2
        let scrollRect = view.convert(tableView.enclosingScrollView!.frame,
                                      from: tableView.enclosingScrollView)
        let tableOffset = view.bounds.height - scrollRect.minX - scrollRect.height
        let height = tableOffset + rowBottom
        
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
        return owningTextField.suggestionDelegate?.viewFor(tableView, item: shownItems[row])
    }
}

extension SuggestionsViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return shownItems.count
    }
    
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return shownItems[row]
    }
}
