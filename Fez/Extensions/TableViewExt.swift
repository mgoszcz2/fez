//
//  TableViewExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 21/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSTableView {
    // Thanks https://stackoverflow.com/questions/13553935/
    func configureColumnMenuShowing(_ showing: [NSUserInterfaceItemIdentifier]) {
        let menu = NSMenu()
        tableColumns.forEach { column in
            let item = NSMenuItem()
            item.title = column.title
            item.action = #selector(toggleColumn(_:))
            item.target = self
            item.representedObject = column
            item.isHidden = !showing.contains(column.identifier)
            item.state = (!column.isHidden).menuState
            menu.addItem(item)
        }
        print("Setting menu \(menu)")
        headerView!.menu = menu
    }
    
    @objc private func toggleColumn(_ sender: NSMenuItem) {
        let column = sender.representedObject as! NSTableColumn
        column.isHidden = !column.isHidden
        sender.state = (!column.isHidden).menuState
    }
}
