import Foundation
import RxSwift
import RxCocoa

// https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Operators.swift#L20

infix operator <-> {
}

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUI = variable.asObservable().bindTo(property)
    
    let bindToVariable = property.subscribe(onNext: { n in
        variable.value = n
    }, onCompleted: {
        bindToUI.dispose()
    })
    
    return StableCompositeDisposable.create(bindToUI, bindToVariable)
}