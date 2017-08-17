//
//  SuggestingTextField.swift
//  Warzone
//
//  Created by Maciej Goszczycki on 16/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

public protocol Suggestable: class {
    var title: String { get }
}

public protocol SuggestionDelegate {
    func viewFor(_ tableView: NSTableView, item: Suggestable) -> NSView;
    func suggestionFor(_ textField: SuggestingTextField) -> [Suggestable];
    func controllerFor(_ textField: SuggestingTextField) -> SuggestionsViewController;
}

public class SuggestingTextField: NSTextField {
    public var suggestionDelegate: SuggestionDelegate?
    
    private var suggestionsWindow: NSWindow?
    private var suggestionsViewController: SuggestionsViewController?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
}

extension SuggestingTextField: NSTextFieldDelegate {
    public func control(_ control: NSControl,
                        textView: NSTextView,
                        doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveUp(_:)) {
            print("up")
            return true
            
        } else if commandSelector == #selector(moveDown(_:)) {
            print("down")
            return true
            
        } else if commandSelector == #selector(cancelOperation(_:)) {
            suggestionsWindow?.close()
            return true
        }
        return false
    }
    
    public override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        
        if suggestionsWindow == nil {
            let ctrl = suggestionDelegate!.controllerFor(self)
            let window = NSWindow(contentViewController: ctrl)
            window.styleMask = [.borderless]
            
            window.parent = self.window // Pair the windows (self important!)
            suggestionsWindow = window
            suggestionsViewController = ctrl
        }
        
        let movedBounds = bounds.offsetBy(dx: 0, dy: bounds.height)
        let frame = window!.convertToScreen(convert(movedBounds, to: nil))
        suggestionsWindow!.setFrame(frame, display: false)
        suggestionsWindow!.makeKeyAndOrderFront(self)
    }
    
    public override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        if !suggestionsWindow!.isVisible {
            suggestionsWindow!.orderFront(self)
        }
        suggestionsViewController?.showItems([])
    }
    
    public override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        suggestionsWindow?.close()
    }
}
