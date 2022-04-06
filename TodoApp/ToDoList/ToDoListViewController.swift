//
//  ToDoListViewController.swift
//  TodoApp
//
//  Created by Andrew_Alekseyuk on 4.04.22.
//

import UIKit
import Combine

class ToDoListViewController: UIViewController {

    let viewModel = ToDoListViewModel()
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let initialLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        checkIsTableViewEmpty()
        tableView.reloadData()
    }

    func setUp() {
        setUpNavigationBar()
        setUpTableView()
        seUpSubscription()
    }

    func setUpNavigationBar() {
        title = "My tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusPressed)
        )
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.edgesToSuperview()
        self.tableView.register(
            UINib(nibName: "TaskTableViewCell", bundle: nil),
            forCellReuseIdentifier: "TaskTableViewCell"
        )
    }

    func seUpSubscription() {
        DataStorage.shared.reloadSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showBanner()
            }
            .store(in: &viewModel.subscriptions)
    }

    func showBanner() {
        let bannerLabel = UILabel()
        bannerLabel.frame.size = CGSize(width: 200, height: 44)
        bannerLabel.center = view.center
        bannerLabel.frame.origin.y = self.view.frame.size.height
        bannerLabel.backgroundColor = .systemGreen
        bannerLabel.text = "The entry was added"
        bannerLabel.textColor = .black
        bannerLabel.textAlignment = .center
        bannerLabel.layer.cornerRadius = bannerLabel.frame.height / 4
        bannerLabel.clipsToBounds = true
        view.addSubview(bannerLabel)
        bannerLabel.bringSubviewToFront(view)
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseInOut) {
            bannerLabel.frame.origin.y -= 100
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseInOut) {
                bannerLabel.frame.origin.y += 100
            } completion: { _ in
                bannerLabel.removeFromSuperview()
            }
        }
    }

    func checkIsTableViewEmpty() {
        if DataStorage.shared.tasksArray.isEmpty {
            initialLabel.translatesAutoresizingMaskIntoConstraints = true
            initialLabel.center = self.view.center
            initialLabel.frame.size = CGSize(width: view.frame.width / 2, height: 100)
            initialLabel.numberOfLines = 0
            initialLabel.text = "Press + to add the task"
            initialLabel.layer.opacity = 0
            self.view.addSubview(initialLabel)
            UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveLinear, animations: {
                self.initialLabel.layer.opacity = 1.0
            }, completion: nil)
        } else {
            initialLabel.removeFromSuperview()
        }
    }

    @objc func plusPressed() {
        let targetViewController = NewEntryViewController(
            nibName: "NewEntryViewController",
            bundle: nil
        )
        self.present(targetViewController, animated: true, completion: nil)
    }
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataStorage.shared.tasksArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TaskTableViewCell",
            for: indexPath
        ) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(item: DataStorage.shared.tasksArray[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(
            style: .normal,
            title: "Delete",
            handler: { (action: UIContextualAction, view: UIView, success:(Bool) -> Void) in
                DispatchQueue.main.async {
                    self.showDeleteWarning(for: indexPath)
                }
                success(true)
            })
        modifyAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }

    func showDeleteWarning(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Warning",
            message: "Do you want to delete entry with deadline: \n\(DataStorage.shared.tasksArray[indexPath.row].date)",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            DispatchQueue.main.async {
                DataStorage.shared.tasksArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                DataStorage.shared.saveToUserDefaults()
                self.checkIsTableViewEmpty()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
