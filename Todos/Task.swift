//
//  Task.swift
//  Quotes
//
//  Created by Subkhan Sarif on 23/03/19.
//  Copyright © 2019 Subkhan Sarif. All rights reserved.
//

import Foundation

struct Task {
    let id: Int
    let title: String
    let time: String
    let location: String?
    var isDone: Bool = false
    
    static let all: [Task] = [
    ]
}

extension Task: CustomStringConvertible {
    var description: String {
        return "\(title) \n\(time)"
    }
}
