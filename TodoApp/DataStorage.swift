//
//  DataStorage.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import Foundation
import Combine

class DataStorage {
    static let shared = DataStorage()

    public var tasksArray: [Task] = []
    var reloadSubject = PassthroughSubject<Void, Never>()

    init() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.object(forKey: "data") as? Data {
            if let decodedData = try? decoder.decode([Task].self, from: savedData) {
                tasksArray = decodedData
            }
        }
    }

    public func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasksArray) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "data")
        }
    }
}
