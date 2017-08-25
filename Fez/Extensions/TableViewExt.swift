//
//  TableViewExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 21/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSTableView {
    func shrinkAll() {
        for column in tableColumns {
            column.width = column.minWidth
        }
    }
    
    // Thanks https://stackoverflow.com/questions/13553935/
    func configureColumnMenuShowing(_ showing: [NSUserInterfaceItemIdentifier]) {
        // Hide the columns
        var toMove = [Int]()
        for (i, column) in tableColumns.enumerated() {
            column.isHidden = !showing.contains(column.identifier)
            if column.isHidden {
                toMove.append(i)
            }
        }
        
        // Move hidden columns to end
        for ix in toMove.reversed() {
            moveColumn(ix, toColumn: tableColumns.count - 1)
        }
        shrinkAll()
        
        // Generate the menu
        let menu = NSMenu()
        for column in tableColumns {
            let item = NSMenuItem()
            item.title = column.title
            item.action = #selector(toggleColumn(_:))
            item.target = self
            item.representedObject = column
            item.state = (!column.isHidden).menuState
            menu.addItem(item)
        }
        headerView!.menu = menu
    }
    
    @objc private func toggleColumn(_ sender: NSMenuItem) {
        let column = sender.representedObject as! NSTableColumn
        column.isHidden = !column.isHidden
        sender.state = (!column.isHidden).menuState
        shrinkAll()
    }
}
