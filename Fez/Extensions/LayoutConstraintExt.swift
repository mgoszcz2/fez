//
//  LayoutConstraintExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension NSLayoutConstraint {
    /// Return a new constraint with it's modifer changed
    func withMultiplier(_ multipler: Double) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!,
                                  attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem,
                                  attribute: self.secondAttribute,
                                  multiplier: CGFloat(multipler),
                                  constant: 0.0)
    }
}
