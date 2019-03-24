//
//  NewTaskViewController.swift
//  Quotes
//
//  Created by Subkhan Sarif on 23/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet var taskTitle: NSTextField!
    @IBOutlet var taskTime: NSDatePicker!
    @IBOutlet var addButton: NSButton!
    @IBOutlet var useTimeCheckbox: NSButton!
    
    var handler: ((String, String, Bool, Any?) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        taskTime.dateValue = Date()
    }
    
    func setTitle(title: String) {
        taskTitle.stringValue = title
    }
    
    func setTime(time: String?) {
        if time != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy HH:mm"
            taskTime.dateValue = formatter.date(from: time!) ?? Date()
        }
    }
    
    func setIncludeTime(include: Bool) {
        if include {
            useTimeCheckbox.state = .on
        } else {
            useTimeCheckbox.state = .off
        }
    }
    
    func getTitle() -> String {
        return taskTitle.stringValue
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let str = formatter.string(from: taskTime.dateValue)
        return str
    }
    
    func getIncludeTime() -> Bool {
        if useTimeCheckbox.state == .on {
            return true
        } else {
            return false
        }
    }
    
}

extension NewTaskViewController {
    static func freshController(handler: @escaping (String, String, Bool, Any?) -> Void) -> NewTaskViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("NewTaskViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NewTaskViewController else {
            fatalError("Why can't I find NewTaskViewController? - Check Main.storyboard")
        }
        viewcontroller.handler = handler
        return viewcontroller
    }
    @IBAction func addTask(_ sender: NSButton) {
        handler?(getTitle(), getTime(), getIncludeTime(), sender)
    }
}
