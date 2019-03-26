//
//  PreferenceViewController.swift
//  Todos
//
//  Created by Subkhan Sarif on 26/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    @IBOutlet weak var checkUseBeautifulLayout: NSButton!
    private var preference: PreferenceModel = PreferenceModel.defaultPref()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load preference
        loadPreference()
        
        if preference.useDynamicLayout {
            checkUseBeautifulLayout.state = .on
        }
        
        (NSApplication.shared.delegate as? AppDelegate)?.closeBeautifulWindow()
    }
    
    override func viewWillDisappear() {
        // save preference
        savePreference()
    }
    
    private func savePreference() {
        let jsonEncoder = JSONEncoder()
        let jsonDataTask = try! jsonEncoder.encode(preference)
        let prefJson = String(data: jsonDataTask, encoding: String.Encoding.utf8)
        
        UserDefaults().set(prefJson, forKey: "preference")
    }
    
    private func loadPreference() {
        let jsonDecoder = JSONDecoder()
        let prefJson = UserDefaults().string(forKey: "preference") ?? ""
        let prefData = prefJson.data(using: String.Encoding.utf8)
        if prefData != nil {
            if let pref = try? jsonDecoder.decode(PreferenceModel.self, from: prefData!) {
                self.preference = pref
            } else {
                self.preference = PreferenceModel.defaultPref()
            }
        }
    }
    
    @IBAction func onUseBeautifulLayoutCheck(_ sender: NSButton) {
        preference.useDynamicLayout = sender.state == .on
    }
    
}
