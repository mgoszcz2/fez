//
//  SuggestionsViewController.swift
//  Warzone
//
//  Created by Maciej Goszczycki on 16/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Cocoa

public class SuggestionsViewController: NSViewController {
    @IBOutlet private weak var tableView: NSTableView!
    
    internal var delegate: SuggestionDelegate!
    var showItems: [Suggestable] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func showItems(_ items: [Suggestable]) {
        showItems = items
        tableView.reloadData()
    }
}

extension SuggestionsViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return delegate.viewFor(tableView, item: showItems[row])
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
