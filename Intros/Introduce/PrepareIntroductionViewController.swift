import Foundation
import UIKit
import RxSwift
import Cartography
import BEMCheckBox
import CleanroomLogger

class ShareTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shareCheck: BEMCheckBox!
}

class PrepareIntroductionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel: PrepareIntroductionViewModel!;
    
    @IBOutlet
    weak var sharingTable: UITableView!
    
    override func viewDidLoad() {
        sharingTable.dataSource = self
        sharingTable.delegate = self
        sharingTable.registerNib(UINib(nibName: "ShareTableViewCell", bundle: nil), forCellReuseIdentifier: "shareCell");
        
        for shareable in viewModel.shareables {
            shareable.shouldShare.asObservable().bindNext { value in
                Log.info?.message("Share \(shareable.name)? \(value)")
            }.addDisposableTo(rx_disposeBag)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shareables.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareCell") as! ShareTableViewCell;
        let shareable = viewModel.shareables[indexPath.row]
        
        cell.nameLabel.text = shareable.name
        (cell.shareCheck.rx_value <-> shareable.shouldShare).addDisposableTo(rx_disposeBag)
        cell.shareCheck.on = shareable.shouldShare.value
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        let shareable = viewModel.shareables[indexPath.row]
//        Log.info?.message("Selected \(indexPath)")
//        shareable.shouldShare.value = !shareable.shouldShare.value
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        Log.info?.message("Will select \(indexPath.row)")
        let shareable = viewModel.shareables[indexPath.row]
        shareable.shouldShare.value = !shareable.shouldShare.value
        return nil
    }
    
    static func instantiate(viewModel: PrepareIntroductionViewModel) -> PrepareIntroductionViewController {
        let vc = UIStoryboard(name: "Introduce", bundle: nil).instantiateViewControllerWithIdentifier("PrepareIntroductionVC") as! PrepareIntroductionViewController;
        vc.viewModel = viewModel;
        return vc;
    }
}