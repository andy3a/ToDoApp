//
//  Task.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import Foundation

class Task: Codable {

    let name: String
    let type: TaskType
    let date: String

    init(name: String, type: TaskType, date: String) {
        self.name = name
        self.type = type
        self.date = date
    }
}
