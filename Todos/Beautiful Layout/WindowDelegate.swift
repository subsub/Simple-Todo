//
//  WindowDelegate.swift
//  Todos
//
//  Created by Subkhan Sarif on 27/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Cocoa

protocol WindowDelegate {
    func preferenceUpdated(pref: PreferenceModel)
    func viewWillDisappear(pref: PreferenceModel)
}
