import Foundation

import Swinject
import Motif

final class SetupPage: Page {
    static var container = Container(parent: AppSetup.rootContainer) { container in
        container.registerForStoryboard(SetupViewController.self) { r, c in
            c.theme = r.resolve(MTFTheme.self)
        }
    }
    
    static var storyboard: SwinjectStoryboard {
        return SwinjectStoryboard.create(name: "Setup", bundle: nil, container: SetupPage.container)
    }
    
    func createViewController() -> UIViewController {
        return SetupPage.storyboard.instantiateInitialViewController()!
    }
}