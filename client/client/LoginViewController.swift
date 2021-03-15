import UIKit
import Alamofire

struct User: Codable {
    enum Right: String, Codable {
        case read = "READ"
        case write = "WRITE"
        case delete = "DELETE"
        case modifyRights = "MODIFY_RIGHTS"
    }

    let id: UInt
    let login: String
    let password: String
    let rights: [Right]
}

var currentUser: User?

class LoginViewController: BaseViewController {
    @IBOutlet private var loginTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!

    private let segueHandler = SegueHandler()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        [loginTextField, passwordTextField].forEach { $0.text = "" }
    }

    @IBAction private func confirmButtonTapped(_ sender: UIButton) {
        guard let login = loginTextField.text,
              let password = passwordTextField.text,
              !login.isEmpty,
              !password.isEmpty else {
            showAlert(message: "Fields can not be empty")
            return
        }

        ApiCaller.makeRequest(
            endPoint: "user",
            method: .get,
            queryParams: [
                "login": login,
                "password": password.md5
            ],
            type: User.self
        )
        .onSuccess { [weak self] user in
            guard let self = self else {
                return
            }

            currentUser = user
            self.segueHandler.perform(from: self, identifier: "ShowDataViewController") { _ in
                let backItem = UIBarButtonItem()
                backItem.title = "Log out"
                self.navigationItem.backBarButtonItem = backItem
            }
        }
        .onFailure { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }
        
    }
}

