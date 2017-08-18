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
    /// Return a view, simmilar to how NSTableViewDelegate works
    func viewFor(_ tableView: NSTableView, item: Suggestable) -> NSView;
    /// Pool of suggestions
    func suggestionFor(_ textField: SuggestingTextField) -> [Suggestable];
    /// Return a new instance of the view controller
    func controllerFor(_ textField: SuggestingTextField) -> SuggestionsViewController;
    /// Default limit is set to 10
    func suggestionLimit(_ textField: SuggestingTextField) -> Int
}

public extension SuggestionDelegate {
    func suggestionLimit(_ textField: SuggestingTextField) -> Int {
        return 10
    }
}

public class SuggestingTextField: NSTextField {
    /// Delegate
    public var suggestionDelegate: SuggestionDelegate?
    private var suggestionsController: SuggestionsViewController?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
    
    public override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if suggestionsController == nil {
            let ctrl = suggestionDelegate!.controllerFor(self)
            ctrl.owningTextField = self
            suggestionsController = ctrl
        }
        
        suggestionsController?.show(suggestionDelegate!.suggestionFor(self))
        return true
    }
}

extension SuggestingTextField: NSTextFieldDelegate {
    public func control(_ control: NSControl,
                        textView: NSTextView,
                        doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveUp(_:)) {
            suggestionsController?.moveUp(self)
            return true
            
        } else if commandSelector == #selector(moveDown(_:)) {
            suggestionsController?.moveDown(self)
            return true
            
        } else if commandSelector == #selector(cancelOperation(_:)) {
            suggestionsController?.close()
            return true
        }
        return false
    }
    
    public override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        suggestionsController?.show(suggestionDelegate!.suggestionFor(self).filter {
            $0.title.lowercased().contains(stringValue.lowercased()) || stringValue.isEmpty
        })
    }
    
    public override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        suggestionsController?.close()
    }
}
