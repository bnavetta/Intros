import Foundation
import UIKit

// Sort of like the Android MVVM issues where you need an Activity for everything

struct ViewControllerHolder {
    static var instance = ViewControllerHolder()
    
    private var currentVC: ViewController?
    
    func presentViewController(viewController: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        currentVC?.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func dismissViewController(animated: Bool = false, completion: (() -> Void)? = nil) {
        currentVC?.dismissViewControllerAnimated(animated, completion: completion)
    }
    
    func pushViewcontroller(viewController: UIViewController, animated: Bool) {
        if let navigationController = currentVC?.navigationController {
            navigationController.pushViewController(viewController, animated: animated)
        }
        else {
            currentVC?.presentViewController(viewController, animated: animated, completion: nil)
        }
    }
    
    func popViewController(animated: Bool) {
        if let navigationController = currentVC?.navigationController {
//            print(navigationController.viewControllers)
            navigationController.popViewControllerAnimated(animated)
//            print("Popped", popped, " -> ", navigationController.viewControllers)
        }
        else {
            currentVC?.dismissViewControllerAnimated(animated, completion: nil)
        }
    }
}

class ViewController: UIViewController {
    override func viewWillAppear(animated: Bool) {
        ViewControllerHolder.instance.currentVC = self
    }
}