//
//  DisplayLink.swift
//  Fez
//
//  Created by Maciej Goszczycki on 23/08/2017.
//  Copyright © 2017 Maciej. All rights reserved.
//

import Foundation

// Thanks (inspired by) https://github.com/avaidyam/Parrot/blob/master/MochaUI/DisplayLink.swift
public class DisplayLink {
    private let selector: Selector
    private weak var target: AnyObject?
    private var displayLink: CVDisplayLink?
    private var startTimestamp: TimeInterval = 0
    
    /// Make the display link wrapper. Selectors argument is an NSNumber interval since start
    init(target: AnyObject, selector: Selector) {
        self.selector = selector
        self.target = target
    }
    
    public func start() {
        let _ = self.target
        let error = CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let link = displayLink, error == kCVReturnSuccess else {
            print("Fez could not create a display link")
            displayLink = nil
            return
        }
        CVDisplayLinkSetOutputHandler(link) { _,_,_,_,_  in
            let interval: TimeInterval = NSDate().timeIntervalSinceReferenceDate - self.startTimestamp
            DispatchQueue.main.async {
                let _ = self.target?.perform(self.selector, with: NSNumber(value: interval))
            }
            return kCVReturnSuccess
        }
        CVDisplayLinkStart(link)
        startTimestamp = NSDate().timeIntervalSinceReferenceDate
    }
    
    public func stop() {
        if let link = displayLink {
            CVDisplayLinkStop(link)
        }
    }
}
