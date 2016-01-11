import Foundation
import RxSwift

extension ConcurrentDispatchQueueScheduler {
    class var backgroundInstance: ConcurrentDispatchQueueScheduler {
        return ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)
    }
    
    class var defaultInstance: ConcurrentDispatchQueueScheduler {
        return ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
    }
}