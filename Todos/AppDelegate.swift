//
//  AppDelegate.swift
//  Quotes
//
//  Created by Subkhan Sarif on 23/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var tasks: [Task] = Task.all
    var done: [Task] = Task.all
    
    var popovers: [NSPopover] = []
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadData()
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("checklist"))
            button.imagePosition = NSControl.ImagePosition.imageLeading
            button.title = "\(self.tasks.count) tasks"
        }
        
        createMenu()
        
//        popover.contentViewController = QuotesViewControllwer.freshController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self {
                strongSelf.popovers.forEach({ (popover) in
                    if popover.isShown {
                        strongSelf.closePopover(sender: event)
                    }
                })
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        saveData()
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        let jsonDataTask = try! jsonEncoder.encode(tasks)
        let jsonDataDone = try! jsonEncoder.encode(done)
        let tasksJson = String(data: jsonDataTask, encoding: String.Encoding.utf8)
        let doneJson = String(data: jsonDataDone, encoding: String.Encoding.utf8)
        
        UserDefaults().set(tasksJson, forKey: "tasks")
        UserDefaults().set(doneJson, forKey: "done")
    }
    
    func loadData() {
        let jsonDecoder = JSONDecoder()
        let tasksJson = UserDefaults().string(forKey: "tasks") ?? "[]"
        let doneJson = UserDefaults().string(forKey: "done") ?? "[]"
        let tasksData = tasksJson.data(using: String.Encoding.utf8)
        let doneData = doneJson.data(using: String.Encoding.utf8)
        if tasksData != nil {
            self.tasks = try! jsonDecoder.decode([Task].self, from: tasksData!)
        }
        if doneData != nil {
            self.done = try! jsonDecoder.decode([Task].self, from: doneData!)
        }
    }
    
    func createMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Add Task", action: #selector(AppDelegate.addTask(_:)), keyEquivalent: "A"))
        menu.addItem(NSMenuItem.separator())
        
        tasks.sort(by: { (task1, task2) -> Bool in
            if task1.time == nil || task2.time == nil {
                var t1 = 1
                var t2 = 1
                if task1.time == nil {
                    t1 *= 10
                }
                if task2.time == nil {
                    t2 *= 10
                }
                return t1 < t2
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH.mm"
            let time1 = formatter.date(from: task1.time!) ?? Date()
            let time2 = formatter.date(from: task2.time!) ?? Date()
            return time1 < time2
        })
        done.sort(by: { (task1, task2) -> Bool in
            if task1.time == nil || task2.time == nil {
                return true
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH.mm"
            let time1 = formatter.date(from: task1.time!) ?? Date()
            let time2 = formatter.date(from: task2.time!) ?? Date()
            return time1 < time2
        })
        for task in tasks {
            let menuItem = NSMenuItem(title: String(describing: task.description), action: #selector(AppDelegate.showOption(_:)), keyEquivalent: "")
            menuItem.attributedTitle = NSAttributedString(string: String(describing: task.description))
            let image = NSImage(named: NSImage.Name("checkBox"))
            menuItem.image = image
            menu.addItem(menuItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Done", action: nil, keyEquivalent: ""))
        for task in done {
            let menuItem = NSMenuItem(title: String(describing: task.description), action: nil, keyEquivalent: "")
            menuItem.attributedTitle = NSAttributedString(string: "\(task.title)")
            menuItem.image = NSImage(named: NSImage.Name("checkBoxChecked"))
            menu.addItem(menuItem)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Delete All Done", action: #selector(AppDelegate.deleteAllDone(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete All", action: #selector(AppDelegate.deleteAll(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func deleteAllDone(_ sender: Any?) {
        done.removeAll()
        if let button = statusItem.button {
            button.title = "\(self.tasks.count) tasks"
        }
        createMenu()
    }
    
    @objc func deleteAll(_ sender: Any?) {
        tasks.removeAll()
        done.removeAll()
        createMenu()
        if let button = statusItem.button {
            button.title = "\(self.tasks.count) tasks"
        }
    }
    
    @objc func showOption(_ menuItem: NSMenuItem) {
        let popover = NSPopover()
        if let menu = self.statusItem.menu {
            let index = menu.index(of: menuItem) - 2
            let viewcontroller = OptionViewController.freshController{ (command, sender) in
                popover.performClose(sender)
                
                if command == "edit" {
                    self.editTask(index: index, task: self.tasks[index])
                } else if command == "delete" {
                    self.tasks.remove(at: index)
                    menu.removeItem(menuItem)
                    menu.update()
                } else if command == "done" {
                    var task = self.tasks[index]
                    task.isDone = true
                    self.tasks.remove(at: index)
                    self.done.append(task)
                    self.done.sort(by: { (task1, task2) -> Bool in
                        if task1.time == nil || task2.time == nil {
                            var t1 = 1
                            var t2 = 1
                            if task1.time == nil {
                                t1 *= 10
                            }
                            if task2.time == nil {
                                t2 *= 10
                            }
                            return t1 < t2
                        }
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/MM/yyyy HH.mm"
                        let time1 = formatter.date(from: task1.time!) ?? Date()
                        let time2 = formatter.date(from: task2.time!) ?? Date()
                        return time1 < time2
                    })
                    let menuItem = NSMenuItem(title: String(describing: task.description), action: nil, keyEquivalent: "")
                    menuItem.attributedTitle = NSAttributedString(string: "\(task.title)")
                    menuItem.image = NSImage(named: NSImage.Name("checkBoxChecked"))
                    self.statusItem.menu?.removeItem(at: index + 2)
                    self.statusItem.menu?.insertItem(menuItem, at: menu.items.count - 5)
                    menu.update()
                    self.saveData()
                }
                
                if let button = self.statusItem.button {
                    let taskCount = self.tasks.filter { (task) -> Bool in
                        !task.isDone
                        }.count
                    button.title = "\(taskCount) tasks"
                }
            }
            popover.contentViewController = viewcontroller
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
        popovers.append(popover)
        eventMonitor?.start()
    }
    
    func editTask(index: Int, task: Task) {
        let popover = NSPopover()
        let viewcontroller = NewTaskViewController.freshController { title, time, isUseTime, sender in
            popover.performClose(sender)
            
            // add menu
            var tm: String? = time
            if !isUseTime {
                tm = nil
            }
            let newTask = Task(id: task.id, title: title, time: tm, location: nil, isDone: task.isDone)
            self.tasks[index] = newTask
            self.tasks.sort(by: { (task1, task2) -> Bool in
                if task1.time == nil || task2.time == nil {
                    var t1 = 1
                    var t2 = 1
                    if task1.time == nil {
                        t1 *= 10
                    }
                    if task2.time == nil {
                        t2 *= 10
                    }
                    return t1 < t2
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH.mm"
                let time1 = formatter.date(from: task1.time!) ?? Date()
                let time2 = formatter.date(from: task2.time!) ?? Date()
                return time1 < time2
            })
            let newIndex = self.tasks.firstIndex(where: { (task) -> Bool in
                task.id == newTask.id
            }) ?? index
            let menuItem = NSMenuItem(title: String(describing: newTask.description), action: #selector(AppDelegate.showOption(_:)), keyEquivalent: "")
            menuItem.attributedTitle = NSAttributedString(string: String(describing: newTask.description))
            menuItem.image = NSImage(named: NSImage.Name("checkBox"))
            self.statusItem.menu?.removeItem(at: index + 2)
            self.statusItem.menu?.insertItem(menuItem, at: newIndex + 2)
            if let button = self.statusItem.button {
                button.title = "\(self.tasks.count) tasks"
            }
            self.saveData()
        }
        popover.contentViewController = viewcontroller
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        
        viewcontroller.setTitle(title: task.title)
        viewcontroller.setIncludeTime(include: task.time != nil)
        viewcontroller.setTime(time: task.time)
        viewcontroller.addButton.title = "Save Task"
        popovers.append(popover)
        eventMonitor?.start()
    }
    
    @objc func addTask(_ sender: Any?) {
        let popover = NSPopover()
        let viewcontroller = NewTaskViewController.freshController { title, time, isUseTime, sender in
            popover.performClose(sender)
            
            // add menu
            var tm: String? = time
            if !isUseTime {
                tm = nil
            }
            let newTask = Task(id: self.tasks.count, title: title, time: tm, location: nil, isDone: false)
            self.tasks.append(newTask)
            self.tasks.sort(by: { (task1, task2) -> Bool in
                if task1.time == nil || task2.time == nil {
                    var t1 = 1
                    var t2 = 1
                    if task1.time == nil {
                        t1 *= 10
                    }
                    if task2.time == nil {
                        t2 *= 10
                    }
                    return t1 < t2
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH.mm"
                let time1 = formatter.date(from: task1.time!) ?? Date()
                let time2 = formatter.date(from: task2.time!) ?? Date()
                return time1 < time2
            })
            let index = self.tasks.firstIndex(where: { (task) -> Bool in
                task.id == newTask.id
            }) ?? self.tasks.count
            let menuItem = NSMenuItem(title: String(describing: newTask.description), action: #selector(AppDelegate.showOption(_:)), keyEquivalent: "")
            menuItem.attributedTitle = NSAttributedString(string: String(describing: newTask.description))
            var image = NSImage(named: NSImage.Name("checkBox"))
            if newTask.isDone {
                image = NSImage(named: NSImage.Name("checkBoxChecked"))
            }
            menuItem.image = image
            self.statusItem.menu?.insertItem(menuItem, at: index + 2)
            if let button = self.statusItem.button {
                button.title = "\(self.tasks.count) tasks"
            }
            self.saveData()
        }
        popover.contentViewController = viewcontroller
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        popovers.append(popover)
        eventMonitor?.start()
    }
    
    @objc func printQuote(_ sender: Any?) {
        print("Aku ke print")
    }

//    @objc func togglePopOver(_ sender: Any?) {
//        if popover.isShown {
//            closePopover(sender: sender)
//        } else {
//            showPopover(sender: sender)
//        }
//    }
//
//    func showPopover(sender: Any?) {
//        if let button = statusItem.button {
//            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
//        }
//        eventMonitor?.start()
//    }
//
    func closePopover(sender: Any?) {
        popovers.forEach { (popover) in
            popover.performClose(sender)
        }
        eventMonitor?.stop()
    }

}

