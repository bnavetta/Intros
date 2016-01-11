import Foundation
import UIKit
import RxSwift
import Cartography
import BEMCheckBox
import CleanroomLogger

class ShareTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shareCheck: BEMCheckBox!
    
    var viewModel: ShareInfoViewModel! {
        didSet {
            nameLabel.text = viewModel.name
            (shareCheck.rx_value <-> viewModel.shareChecked).addDisposableTo(rx_disposeBag)
            viewModel.enabled.asDriver().driveNext { enabled in
                self.nameLabel.enabled = enabled
                self.shareCheck.hidden = !enabled
            }.addDisposableTo(rx_disposeBag)
        }
    }
}

class PrepareIntroductionViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var viewModel: IntroduceViewModelType!
    
    @IBOutlet
    weak var sharingTable: UITableView!
    
    override func viewDidLoad() {
        sharingTable.dataSource = self
        sharingTable.delegate = self
        sharingTable.registerNib(UINib(nibName: "ShareTableViewCell", bundle: nil), forCellReuseIdentifier: "shareCell");
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shareInfoCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareCell") as! ShareTableViewCell;
        let shareInfoVM = viewModel.shareInfoAtIndexPath(indexPath)
        cell.viewModel = shareInfoVM
        
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let shareInfo = viewModel.shareInfoAtIndexPath(indexPath)
        shareInfo.shareChecked.value = !shareInfo.shareChecked.value
        return nil
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let shareInfoVM = viewModel.shareInfoAtIndexPath(indexPath)
        return shareInfoVM.enabled.value
    }
}