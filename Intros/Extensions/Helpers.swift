import Foundation

// http://nshipster.com/new-years-2016/

@warn_unused_result
public func Init<T>(value: T, @noescape block: (object: T) -> Void) -> T {
    block(object: value)
    return value
}