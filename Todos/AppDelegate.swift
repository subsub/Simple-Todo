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
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var menuDone: NSMenuItem!
    @IBOutlet weak var menuSeparator: NSMenuItem!
    
    @IBAction func onNewTaskClick(_ sender: NSMenuItem) {
        addTask(sender)
    }
    @IBAction func onDeleteAllDoneClick(_ sender: NSMenuItem) {
        deleteAllDone(sender)
    }
    @IBAction func onDeleteAllClick(_ sender: NSMenuItem) {
        deleteAll(sender)
    }
    @IBAction func onQuitClick(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadData()
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("checklist"))
            button.imagePosition = NSControl.ImagePosition.imageLeading
            button.title = "\(self.tasks.count) tasks"
        }
        
        createMenu()
        
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
    
    func sortTask() {
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
    }
    
    func createMenuTask(task: Task, action: Selector?) -> NSMenuItem{
        let menuItem = NSMenuItem(title: String(describing: task.description), action: action, keyEquivalent: "")
        menuItem.attributedTitle = NSAttributedString(string: String(describing: task.description))
        var image = NSImage(named: NSImage.Name("checkBox"))
        if task.isDone {
            menuItem.attributedTitle = NSAttributedString(string: "\(task.title)")
            image = NSImage(named: NSImage.Name("checkBoxChecked"))
        }
        menuItem.image = image
        return menuItem
    }
    
    func createMenu() {
        sortTask()
        var index = mainMenu.index(of: menuSeparator) + 1
        for task in tasks {
            mainMenu.insertItem(self.createMenuTask(task: task, action: #selector(AppDelegate.showOption(_:))), at: index)
            index += 1
        }
        for task in done {
            let index = mainMenu.index(of: menuDone)
            mainMenu.insertItem(self.createMenuTask(task: task, action: nil), at: index + 1)
        }
        statusItem.menu = mainMenu
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
                    self.sortTask()
                    let menuItem = self.createMenuTask(task: task, action: nil)
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
            self.sortTask()
            let newIndex = self.tasks.firstIndex(where: { (task) -> Bool in
                task.id == newTask.id
            }) ?? index
            let menuItem = self.createMenuTask(task: newTask, action: #selector(AppDelegate.showOption(_:)))
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
            self.sortTask()
            let index = self.tasks.firstIndex(where: { (task) -> Bool in
                task.id == newTask.id
            }) ?? self.tasks.count
            let menuItem = self.createMenuTask(task: newTask, action: #selector(AppDelegate.showOption(_:)))
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

    func closePopover(sender: Any?) {
        popovers.forEach { (popover) in
            popover.performClose(sender)
        }
        eventMonitor?.stop()
    }

}

