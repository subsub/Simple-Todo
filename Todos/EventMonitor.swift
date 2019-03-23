//
//  EventMonitor.swift
//  Quotes
//
//  Created by Subkhan Sarif on 23/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

public class EventMonitor {
    private var started: Bool = false
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
        started = false
    }
    
    func start() {
        if !started {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
        started = true
    }
    
    func isStarted() -> Bool {
        return started
    }
    
    func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
        started = false
    }
}
