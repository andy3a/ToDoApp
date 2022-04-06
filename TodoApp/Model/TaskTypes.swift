//
//  TaskTypes.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import UIKit

enum TaskType: String, CaseIterable, Codable {
    case work
    case purchases
    case other

    public static var defaultValue: TaskType {
        return .work
    }

    var backgroundColor: UIColor {
        switch self {
        case .work:
            return .red
        case .purchases:
            return .blue
        case .other:
            return .purple
        }
    }
}
