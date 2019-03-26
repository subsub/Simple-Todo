//
//  PreferenceModel.swift
//  Todos
//
//  Created by Subkhan Sarif on 26/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Foundation

struct PreferenceModel: Codable {
    var useDynamicLayout: Bool = false
}

extension PreferenceModel {
    static func defaultPref() -> PreferenceModel {
        return PreferenceModel(useDynamicLayout: false)
    }
}
