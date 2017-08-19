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

public protocol SuggestionDelegate: class {
    /// Return a view, simmilar to how NSTableViewDelegate works
    func viewFor(_ tableView: NSTableView, item: Suggestable) -> NSView;
    /// Pool of suggestions
    func suggestionFor(_ textField: SuggestingTextField) -> [Suggestable];
    /// Return a new instance of the view controller
    func controllerFor(_ textField: SuggestingTextField) -> SuggestionsViewController;
}

open class SuggestingTextField: NSSearchField {
    /// Delegate
    open weak var suggestionDelegate: SuggestionDelegate?
    /// Selector to use when a selection is made
    public var selectionAction: Selector?
    /// Target for selection action. First argument text field, second the item
    public weak var selectionTarget: AnyObject?
    /// Maximum number of suggestions
    @IBInspectable open var suggestionsLimit: Int = 10
    /// Suggestion controller of this text field
    public private(set) var suggestionsController: SuggestionsViewController?
    /// Currently selected item if any
    public var selectedItem: Suggestable? { return suggestionsController?.selectedItem }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }
    
    open override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if suggestionsLimit <= 0 { return true }
        
        if suggestionsController == nil {
            let ctrl = suggestionDelegate!.controllerFor(self)
            ctrl.owningTextField = self
            suggestionsController = ctrl
        }
        
        showSuggestions()
        return true
    }
    
    private func showSuggestions() {
        suggestionsController?.show(suggestionDelegate!.suggestionFor(self).filter {
            $0.title.lowercased().contains(stringValue.lowercased()) || stringValue.isEmpty
        })
    }
    
    /// Send out action that an item has been selected. Clears the input
    open func sendSelectedItem() {
        if selectedItem == nil { return }
        let _ = selectionTarget?.perform(selectionAction!, with: self)
        closeSuggestions()
        stringValue = ""
    }

    /// Close suggestions window externally
    public func closeSuggestions() {
        suggestionsController?.close()
    }
    
    /// Read in new data for suggestions
    open func reloadData() {
        showSuggestions()
    }
}

extension SuggestingTextField: NSSearchFieldDelegate {
    open func control(_ control: NSControl,
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
        } else if commandSelector == #selector(insertNewline(_:)) {
            sendSelectedItem()
            return true
        }
        return false
    }
    
    open override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        showSuggestions()
    }
    
    open override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        closeSuggestions()
    }
}
