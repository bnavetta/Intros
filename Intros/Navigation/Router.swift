import Foundation
import UIKit
import CleanroomLogger

protocol RoutingKey {
    
}

protocol Router {
    func goTo(key: RoutingKey);
}

final class NavigationControllerRouter: Router {
    let navigationController: UINavigationController;
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController;
    }
    
    func goTo(key: RoutingKey) {
        Log.info?.message("Navigating to \(key)");
        navigationController.pushViewController(viewControllerFor(key), animated: true);
    }
    
    private func viewControllerFor(key: RoutingKey) -> UIViewController {
        if let _ = key as? TestRoute {
            return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("viewController");
        }
        else if let _ = key as? PrepareIntroduction {
            let viewModel = PrepareIntroductionViewModelType();
            return PrepareIntroductionViewController.instantiate(viewModel);
        }
        
        fatalError("Unknown route: \(key)");
    }
}