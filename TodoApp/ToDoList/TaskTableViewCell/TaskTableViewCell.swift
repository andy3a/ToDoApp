//
//  TaskTableViewCell.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deadlineDate: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    func configure(item: Task) {
        nameLabel.text = item.name
        typeLabel.layer.backgroundColor = item.type.backgroundColor.cgColor
        typeLabel.text = item.type.rawValue
        deadlineDate.text = item.date
    }
}
