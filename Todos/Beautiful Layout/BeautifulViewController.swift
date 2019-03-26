//
//  BeautifulViewController.swift
//  Todos
//
//  Created by Subkhan Sarif on 26/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class BeautifulViewController: NSViewController {
    @IBOutlet weak var preferenceButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func onPreferenceClick(_ sender: NSButton) {
        let preferenceWindowController = NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "preferences") as? PreferencesWindowController
        preferenceWindowController?.showWindow(sender)
    }
    
}
