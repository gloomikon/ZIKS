import UIKit

class ModifyRightsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    @IBOutlet private var loginTextField: UITextField!
    @IBOutlet private var rightsTextField: UITextField!

    private var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = currentUser else {
            return
        }

        ApiCaller.makeRequest(
            endPoint: "users",
            method: .get,
            queryParams: ["login": user.login],
            type: [User].self
        )
        .onSuccess { [weak self] users in
            self?.users = users
            self?.tableView.reloadData()
        }
        .onFailure { [weak self] error in
            self?.showAlert(message: error.localizedDescription) { _ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let login = loginTextField.text, !login.isEmpty,
              let newRights = rightsTextField.text, !newRights.isEmpty else {
            showAlert(message: "Fields can not be empty")
            return
        }

        guard let user = currentUser else {
            return
        }

        struct BodyParams: Encodable {
            let changer: String
            let login: String
            let rights: [User.Right]
        }

        let rights = newRights.split(separator: " ").map{ String($0) }.compactMap { User.Right(rawValue: $0) }
        ApiCaller.makeRequest(
            endPoint: "user",
            method: .put,
            bodyParams: BodyParams(
                changer: user.login,
                login: login,
                rights: rights
            ),
            type: [User].self
        )
        .onSuccess { [weak self] users in
            self?.users = users
            self?.tableView.reloadData()
        }
        .onFailure { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }
    }
}

extension ModifyRightsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = users[indexPath.row].login
        cell.detailTextLabel?.text = users[indexPath.row].rights
            .map { $0.rawValue }
            .joined(separator: " ")

        return cell
    }
}

extension ModifyRightsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loginTextField.text = users[indexPath.row].login
        rightsTextField.text = users[indexPath.row].rights
            .map { $0.rawValue }
            .joined(separator: " ")
    }
}
