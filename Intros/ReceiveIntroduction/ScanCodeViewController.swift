import Foundation
import UIKit

import Action
import Motif

class ScanCodeViewController: ViewController, UIGestureRecognizerDelegate {
    var viewModel: ScanCodeViewModelType!
    var theme: MTFTheme!
    
    @IBOutlet
    weak var previewView: UIView!
    
    let outlineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.previewLayer.frame = view.frame
        previewView.frame = view.frame
        previewView.layer.addSublayer(viewModel.previewLayer)
        
        outlineView.layer.borderColor = theme.primaryLightColor.CGColor
        outlineView.layer.borderWidth = 2
        view.addSubview(outlineView)
        view.bringSubviewToFront(outlineView)
        
        viewModel.latestCodeBounds.driveNext { bounds in
            self.outlineView.frame = bounds
        }.addDisposableTo(rx_disposeBag)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        outlineView.frame = CGRectZero
        
        viewModel.scanForCode()
            .subscribeNext { vm in
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("importInformation") as! ImportInformationViewController
            viewController.viewModel = vm
            self.navigationController?.pushViewController(viewController, animated: true)
        }.addDisposableTo(rx_disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}