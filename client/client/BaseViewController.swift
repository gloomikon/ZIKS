import UIKit

class BaseViewController: UIViewController {
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let handler = sender as? SegueHandler {
            handler.handle(destination: segue.destination)
        }
    }
}
