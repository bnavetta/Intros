import Foundation
import ContactsUI

import RxSwift
import RxCocoa

class RxContactViewControllerDelegateProxy: DelegateProxy, CNContactViewControllerDelegate, DelegateProxyType {
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        return (object as! CNContactViewController).delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        (object as! CNContactViewController).delegate = delegate as? CNContactViewControllerDelegate
    }
}

extension CNContactViewController {
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxContactViewControllerDelegateProxy.self, self)
    }
    
    public var rx_completed: Observable<CNContact?> {
        return rx_delegate.observe("contactViewController:didCompleteWithContact:")
            .map { ($0[1] as? CNContact) }
    }
}