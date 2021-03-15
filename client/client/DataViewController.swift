import UIKit
import Alamofire

class DataViewController: BaseViewController {

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var dataStrings: [String] = []
    private let segueHandler = SegueHandler()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let currentUser = currentUser else {
            return
        }

        ApiCaller.makeRequest(
            endPoint: "data",
            method: .get,
            queryParams: ["login": currentUser.login],
            type: [String].self
        )
        .onSuccess { [weak self] dataStrings in
            self?.dataStrings = dataStrings
            self?.tableView.reloadData()
        }
        .onFailure { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }

        navigationItem.rightBarButtonItems = []

        navigationItem.rightBarButtonItems?.append(
            .init(barButtonSystemItem: .add, target: self, action: #selector(handleAddButtonTap)))

        navigationItem.rightBarButtonItems?.append(
            .init(
                title: "Modify Rights",
                style: .plain,
                target: self,
                action: #selector(handleModifyRightsButtonTap)
            )
        )
    }

    @objc
    private func handleModifyRightsButtonTap() {
        segueHandler.perform(from: self, identifier: "ShowModifyRightsViewController")
    }

    @objc
    private func handleAddButtonTap() {
        segueHandler.perform(from: self, identifier: "ShowNewDataViewController")
    }
}

extension DataViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStrings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dataStrings[indexPath.row]
        return cell
    }
}

extension DataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let user = currentUser else {
            return
        }

        struct BodyParams: Encodable {
            let login: String
            let index: Int
        }

        if (editingStyle == .delete) {
            ApiCaller.makeRequest(
                endPoint: "data",
                method: .delete,
                bodyParams: BodyParams(
                    login: user.login,
                    index: indexPath.row
                ),
                type: [String].self
            )
            .onSuccess { [weak self] strings in
                self?.dataStrings = strings
                self?.tableView.reloadData()
            }
            .onFailure{ [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            }
        }
    }
}
