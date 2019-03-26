//
//  BeautifulWindow.swift
//  Todos
//
//  Created by Subkhan Sarif on 26/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class BeautifulWindow: NSWindowController, WindowDelegate {

    internal var isVisible: Bool = false
    private var rect: NSRect = NSRect(x: 0, y: 0, width: 300, height: 600)
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.activate(ignoringOtherApps: true)
        window?.setContentSize(NSSize(width: rect.width, height: rect.height))
        isVisible = true
    }
    
    func setRect(rect: NSRect) {
        self.rect = window?.convertToScreen(rect) ?? self.rect
        window?.setFrameTopLeftPoint(NSPoint(x: rect.origin.x, y: rect.origin.y + 22))
    }
    
    func preferenceUpdated(pref: PreferenceModel) {
        if !pref.useDynamicLayout {
            window?.close()
        }
    }
    
    func viewWillDisappear(pref: PreferenceModel) {
        if !pref.useDynamicLayout {
            window?.close()
        }
    }
    
    override func close() {
        isVisible = false
        super.close()
    }

}
