import Foundation
import RxSwift

// https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/HelperFunctions.swift#L40

func void<T>(_: T) -> Void {
    return Void()
}

extension Observable {
    
    func doOnNext(onNext: Element throws -> Void) -> Observable<Element> {
        return doOn { event throws in
            switch event {
            case .Next(let value):
                try onNext(value)
            default:
                break
            }
        }
    }
    
    func doOnCompleted(onCompleted: () throws -> Void) -> Observable<Element> {
        return doOn { event throws in
            switch event {
            case .Completed:
                try onCompleted()
            default:
                break
            }
        }
    }
    
    func doOnError(onError: ErrorType throws -> Void) -> Observable<Element> {
        return doOn { event throws in
            switch event {
            case .Error(let error):
                try onError(error)
            default:
                break
            }
        }
    }
}