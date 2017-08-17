//
//  UrlExt.swift
//  Fez
//
//  Created by Maciej Goszczycki on 17/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

public extension URL {
    /// Resolve security scoped bookmark data
    init(securelyResovlingBookmarkData data: Data) {
        var stale = false
        try! self.init(resolvingBookmarkData: data,
                       options: .withSecurityScope,
                       relativeTo: nil,
                       bookmarkDataIsStale: &stale)!
        if stale {
            print("Stale bookmark data")
        }
    }
    
    /// Get sandbox-ready bookmark data
    func sandboxBookmarkData() -> Data {
        return try! bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess])
    }
}
