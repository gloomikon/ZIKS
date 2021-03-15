import Foundation
import UIKit

class SegueHandler {
    private var handler: ((UIViewController) -> Void)?
    private var identifier: String!

    func perform(from: UIViewController, identifier: String, handler: ((UIViewController) -> Void)? = nil) {
        self.identifier = identifier
        self.handler = handler
        from.performSegue(withIdentifier: identifier, sender: self)
    }

    func handle(destination: UIViewController) {
        handler?(destination)
    }
}
