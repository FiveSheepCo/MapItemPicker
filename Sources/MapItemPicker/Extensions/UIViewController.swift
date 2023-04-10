import UIKit

extension UIViewController {
    var highestPresentedController: UIViewController {
        presentedViewController?.highestPresentedController ?? self
    }
}
