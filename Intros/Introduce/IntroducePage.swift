import Foundation
import UIKit
import Swinject

final class IntroducePage: Page {
    static var container: Container = {
        let container = Container()
        
        container.register(UserManager.self) { _ in UserManagerImpl() }
        
        container.register(IntroduceViewModelType.self) { r in
            let viewModel = IntroduceViewModel(userManager: r.resolve(UserManager.self)!)
            return viewModel
        }.inObjectScope(.None)
        
        container.registerForStoryboard(IntroduceViewController.self) { r, c in
            c.viewModel = r.resolve(IntroduceViewModelType.self)
        }
        
        return container
    }()
    
    static var storyboard: SwinjectStoryboard {
        return SwinjectStoryboard.create(name: "Introduce", bundle: nil, container: IntroducePage.container)
    }
    
    func createViewController() -> UIViewController {
        return IntroducePage.storyboard.instantiateInitialViewController()!
    }
}
