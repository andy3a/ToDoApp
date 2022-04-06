//
//  NewEntryViewController.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import UIKit
import TinyConstraints
import Combine

class NewEntryViewController: UIViewController {

    @IBOutlet weak var nameTextEditor: UITextView!
    @IBOutlet weak var typePickerContainer: UIView!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    let viewModel = NewEntryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    func setUp() {
        setUpSegmentedPicker()
        setUpDatePicker()
        setUpTextEditor()
        saveButton.isEnabled = false
        orientationChanged(notification: nil)
        if self.traitCollection.userInterfaceStyle == .dark {
            nameTextEditor.backgroundColor = .black
        } else {
            nameTextEditor.backgroundColor = .white
        }
    }

    func setUpSegmentedPicker() {
        let items  = TaskType.allCases.map {$0.rawValue}
        let segmentedPicker = UISegmentedControl(items: items)
        segmentedPicker.selectedSegmentIndex = 0
        segmentedPicker.selectedSegmentTintColor = .systemBlue
        segmentedPicker.addTarget(self, action: #selector(changeTaskType), for: .valueChanged)
        self.view.addSubview(segmentedPicker)
        segmentedPicker.edges(to: typePickerContainer)
    }

    func setUpDatePicker() {
        viewModel.datePicker.timeZone = NSTimeZone.local
        self.view.addSubview(viewModel.datePicker)
        viewModel.datePicker.center(in: datePickerContainer)
    }

    func setUpTextEditor() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapRecognizer)
        nameTextEditor.layer.cornerRadius = 6
    }

    func showAlert() {
        let alert = UIAlertController(title: "Warning", message: "Entry cannot be written", preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .cancel) { _ in
            DispatchQueue.main.async {
                guard let name = self.nameTextEditor.text else {
                    self.saveButton.isEnabled = false
                    return
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
                let newTask = Task(
                    name: name,
                    type: self.viewModel.selectedTaskType,
                    date: dateFormatter.string(from: self.viewModel.datePicker.date))
                DataStorage.shared.tasksArray.insert(newTask, at: 0)
                DataStorage.shared.saveToUserDefaults()
                DataStorage.shared.reloadSubject.send()
                self.dismiss(animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }

    @objc func dismissKeyboard() {
        nameTextEditor.resignFirstResponder()
    }

    @objc func orientationChanged(notification: NSNotification?) {
        guard let deviceOrientation =
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.interfaceOrientation else {return}
        switch deviceOrientation {
        case .portrait:
            fallthrough
        case .portraitUpsideDown:
            textViewHeightConstraint.constant = 300
        case .landscapeLeft:
            fallthrough
        case .landscapeRight:
            textViewHeightConstraint.constant = 100
        case .unknown:
            print("unknown orientation")
        @unknown default:
            print("unknown case in orientation change")
        }
    }

    @objc func changeTaskType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.selectedTaskType = .work
        case 1:
            viewModel.selectedTaskType = .purchases
        case 2:
            viewModel.selectedTaskType = .other
        default:
            print("out of index")
        }
    }

    @IBAction func dismissPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let name = nameTextEditor.text else {
            saveButton.isEnabled = false
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        let newTask = Task(
            name: name,
            type: viewModel.selectedTaskType,
            date: dateFormatter.string(from: viewModel.datePicker.date))
        if viewModel.isErrorRequered {
            showAlert()
            viewModel.isErrorRequered = false
        } else {
            DataStorage.shared.tasksArray.insert(newTask, at: 0)
            DataStorage.shared.saveToUserDefaults()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension NewEntryViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // double press return to hide heyboard
        if text.last == "\n" {
            viewModel.returnPressCounter += 1
            if viewModel.returnPressCounter == 2 {
                textView.resignFirstResponder()
                return false
            }
        } else {
            viewModel.returnPressCounter = 0
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let enteredText = textView.text else {return}
        if !enteredText.isEmpty {
            saveButton.isEnabled = true
        }
        if  enteredText.isEmpty {
            saveButton.isEnabled = false
        }
    }
}
