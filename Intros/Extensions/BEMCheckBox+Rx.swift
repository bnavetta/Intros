import Foundation
import UIKit
import RxSwift
import RxCocoa
import CleanroomLogger
import BEMCheckBox

class RxCheckBoxDelegateProxy: DelegateProxy, BEMCheckBoxDelegate, DelegateProxyType {
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        return (object as! BEMCheckBox).delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        (object as! BEMCheckBox).delegate = (delegate as? BEMCheckBoxDelegate)
    }
}

extension BEMCheckBox {
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxCheckBoxDelegateProxy.self, self);
    }
    
    public var rx_value: ControlProperty<Bool> {
        // https://github.com/ReactiveX/RxSwift/blob/2.0.0/RxCocoa/iOS/UIControl%2BRx.swift#L65
        
        let values = rx_delegate.observe("didTapCheckBox:")
            .map { [weak self] _ in self?.on ?? false };
        
        let valueSink: AnyObserver<Bool> = AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                self?.setOn(value, animated: true)
                break;
            case .Error(let error):
                Log.error?.message("Error binding to UI: \(error)");
                break;
            case .Completed:
                break;
            }
        }
        
        return ControlProperty(values: values, valueSink: valueSink)
    }
}