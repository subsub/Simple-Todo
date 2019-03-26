//
//  PreferencesWindowController.swift
//  Todos
//
//  Created by Subkhan Sarif on 26/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.activate(ignoringOtherApps: true)
        self.window?.title = "Preferences"
        
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
