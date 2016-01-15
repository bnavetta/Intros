import Foundation
import UIKit

import RxSwift
import RxCocoa

extension UICollectionView {
    var rx_highlightedCell: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe("collectionView:didHighlightItemAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }
        
        return ControlEvent(events: source)
    }
    
    var rx_unhighlightedCell: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe("collectionView:didUnhighlightItemAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }
        
        return ControlEvent(events: source)
    }
}