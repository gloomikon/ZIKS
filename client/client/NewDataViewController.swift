import UIKit

class NewDataViewController: UIViewController {

    @IBOutlet private var newDataTextField: UITextField!


    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let newData = newDataTextField.text,
              !newData.isEmpty else {
            showAlert(message: "Field can not be empty")
            return
        }

        guard let user = currentUser else {
            return
        }

        ApiCaller.makeRequest(
            endPoint: "data",
            method: .post,
            bodyParams: [
                "login": user.login,
                "string": newData
            ],
            type: [String].self
        )
        .onSuccess { [weak self] _ in
            self?.showAlert(title: "Success", message: "Data inserted")
        }
        .onFailure { [weak self] error in
            self?.showAlert(message: error.localizedDescription)
        }
    }
}
