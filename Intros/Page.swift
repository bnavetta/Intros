import Foundation
import UIKit

import CleanroomLogger

protocol Page {
    func createViewController() -> UIViewController
}

extension UIViewController {
    private struct AssociatedKeys {
        static var PageIndex = "bbni_pageIndex"
    }
    
    var pageIndex: Int? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.PageIndex) as? Int
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.PageIndex, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

class PagedViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let pageController: UIPageViewController
    let pages: [Page]
    let initialIndex: Int
    var currentViewController: UIViewController?
    
    init(pages: [Page], initialIndex: Int) {
        self.pages = pages
        self.initialIndex = initialIndex
        
        pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        
        super.init(nibName: nil, bundle: nil)
        
        pageController.dataSource = self
        pageController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        let initialVC = instantiateViewControllerAtIndex(initialIndex)
        pageController.setViewControllers([initialVC], direction: .Forward, animated: false, completion: nil)
        
        addChildViewController(pageController)
        view.addSubview(pageController.view)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let index = viewController.pageIndex {
            let newIndex = index + 1
            
            if newIndex == pages.count {
                return nil
            }
            
            return instantiateViewControllerAtIndex(newIndex)
        }
        else {
            fatalError("View controller has no page index")
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let index = viewController.pageIndex {
            if index == 0 {
                return nil
            }
            
            return instantiateViewControllerAtIndex(index - 1)
        }
        else {
            fatalError("View controller has no page index")
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        currentViewController = pendingViewControllers.first
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func instantiateViewControllerAtIndex(index: Int) -> UIViewController {
        let vc = pages[index].createViewController()
        vc.pageIndex = index
        return vc
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return currentViewController
    }
}