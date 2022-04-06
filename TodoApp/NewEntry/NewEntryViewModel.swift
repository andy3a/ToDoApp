//
//  NewEntryViewModel.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 5.04.22.
//

import Foundation
import UIKit

class NewEntryViewModel {

    let datePicker: UIDatePicker = UIDatePicker()

    var selectedTaskType = TaskType.defaultValue
    var returnPressCounter = 0
    var isErrorRequered = true

}
