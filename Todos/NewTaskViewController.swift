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
    var handler: ((String, String, Any?) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        taskTime.dateValue = Date()
    }
    
    func setTitle(title: String) {
        taskTitle.stringValue = title
    }
    
    func setTime(time: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        taskTime.dateValue = formatter.date(from: time) ?? Date()
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
    
}

extension NewTaskViewController {
    static func freshController(handler: @escaping (String, String, Any?) -> Void) -> NewTaskViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("NewTaskViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NewTaskViewController else {
            fatalError("Why can't I find NewTaskViewController? - Check Main.storyboard")
        }
        viewcontroller.handler = handler
        return viewcontroller
    }
    @IBAction func addTask(_ sender: NSButton) {
        handler?(getTitle(), getTime(), sender)
    }
}
