import Foundation
import UIKit

import RxSwift
import RxDataSources
import Motif

class SocialImportCell: UICollectionViewCell {
    @IBOutlet
    weak var iconView: UIImageView!
    
    override class func initialize() {
//        mtf_registerThemeProperty("backgroundColor", requiringValueOfClass: UIColor.self) { color, cell, _ in
//            if let color = color as? UIColor, cell = cell as? UICollectionViewCell {
//                cell.backgroundColor = color
//            }
//            return true
//        }
    }
}

class ImportInformationViewController: ViewController, UICollectionViewDelegate {
    var viewModel: ImportInformationViewModelType!
    var theme: MTFTheme!
    
    @IBOutlet
    weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SocialImportSection>()
        dataSource.cellFactory = { colView, indexPath, item in
            let cell = colView.dequeueReusableCellWithReuseIdentifier("SocialImportCell", forIndexPath: indexPath) as! SocialImportCell
            
            cell.iconView.image = item.icon
            
            cell.contentView.layer.cornerRadius = 3.0
            
            self.theme.applyClass("SocialImport", to: cell)
            print(cell.layer.cornerRadius)
            
            return cell
        }
        
        theme.applyClass("SocialImportContainer", to: view)
        
        viewModel.socialImports.map { [$0] }
            .bindTo(collectionView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(rx_disposeBag)
        
        
        collectionView.rx_itemSelected.subscribeNext { indexPath in
            let item = dataSource.itemAtIndexPath(indexPath)
            self.viewModel.importItem(item).subscribe().addDisposableTo(self.rx_disposeBag)
        }
        .addDisposableTo(rx_disposeBag)
        
        collectionView.rx_highlightedCell.subscribeNext { indexPath in
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath)!
            self.theme.applyClass("SocialImportHighlighted", to: cell)
        }
        .addDisposableTo(rx_disposeBag)
        
        collectionView.rx_unhighlightedCell.subscribeNext { indexPath in
            let cell = self.collectionView.cellForItemAtIndexPath(indexPath)!
            self.theme.applyClass("SocialImport", to: cell)
        }
        .addDisposableTo(rx_disposeBag)
    }
}