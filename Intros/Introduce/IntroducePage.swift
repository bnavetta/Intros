import Foundation
import UIKit

import Swinject
import Prephirences
import Motif

final class IntroducePage: Page {
    static var container = Container(parent: AppSetup.rootContainer) { container in
        container.register(IntroduceViewModelType.self) { r in
            let viewModel = IntroduceViewModel(userManager: r.resolve(UserManager.self)!, preferences: r.resolve(MutablePreferencesType.self)!)
            return viewModel
        }.inObjectScope(.None)
            
        container.registerForStoryboard(IntroduceViewController.self) { r, c in
            c.viewModel = r.resolve(IntroduceViewModelType.self)
        }
        
        container.registerForStoryboard(PresentCodeViewController.self) { r, c in
            c.theme = r.resolve(MTFTheme.self)
        }
        
        container.registerForStoryboard(PrepareIntroductionViewController.self) { r, c in
            c.theme = r.resolve(MTFTheme.self)
        }
    }
    
//    static var container: Container = {
//        let container = Container(parent: app)
//        
//        container.register(UserManager.self) { _ in UserManagerImpl() }
//        
//        container.register(IntroduceViewModelType.self) { r in
//            let viewModel = IntroduceViewModel(userManager: r.resolve(UserManager.self)!)
//            return viewModel
//        }.inObjectScope(.None)
//        
//        container.registerForStoryboard(IntroduceViewController.self) { r, c in
//            c.viewModel = r.resolve(IntroduceViewModelType.self)
//        }
//        
//        return container
//    }()
    
    static var storyboard: SwinjectStoryboard {
        return SwinjectStoryboard.create(name: "Introduce", bundle: nil, container: IntroducePage.container)
    }
    
    func createViewController() -> UIViewController {
        return IntroducePage.storyboard.instantiateInitialViewController()!
    }
}
