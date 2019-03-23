//
//  OptionViewController.swift
//  Quotes
//
//  Created by Subkhan Sarif on 23/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class OptionViewController: NSViewController {

    var handler: ((String, Any?) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension OptionViewController {
    static func freshController(handler: @escaping (String, Any?) -> Void) -> OptionViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("OptionViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? OptionViewController else {
            fatalError("Cannot find OptionViewController - Check Main.storyboard")
        }
        viewcontroller.handler = handler
        return viewcontroller
    }
    @IBAction func edit(_ sender: NSButton) {
        handler?("edit", sender)
    }
    
    @IBAction func delete(_ sender: NSButton) {
        handler?("delete", sender)
    }
    
    @IBAction func done(_ sender: NSButton) {
        handler?("done", sender)
    }
}
