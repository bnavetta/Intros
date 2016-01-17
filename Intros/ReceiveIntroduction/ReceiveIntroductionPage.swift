import Foundation
import UIKit

import Swinject
import Motif

final class ReceiveIntroductionPage: Page {
    static var container = Container(parent: AppSetup.rootContainer) { container in
        container.register(ScanCodeViewModelType.self) { r in
            return ScanCodeViewModel(shareService: r.resolve(ShareServiceType.self)!,
                theme: r.resolve(MTFTheme.self)!)
        }.inObjectScope(.None)
        
        container.registerForStoryboard(ScanCodeViewController.self) { r, controller in
            controller.viewModel = r.resolve(ScanCodeViewModelType.self)!
            controller.theme = r.resolve(MTFTheme.self)
        }
        
        container.registerForStoryboard(ImportInformationViewController.self) { r, controller in
            controller.theme = r.resolve(MTFTheme.self)!
        }
    }
    
    static var storyboard: SwinjectStoryboard {
        return SwinjectStoryboard.create(name: "ReceiveIntroduction", bundle: nil, container: container)
    }
    
    func createViewController() -> UIViewController {
        return ReceiveIntroductionPage.storyboard.instantiateInitialViewController()!
    }
}