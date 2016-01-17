import Foundation
import UIKit

import Motif
import RazzleDazzle

class SetupViewController: AnimatedPagingScrollViewController {
    
    /*
     * Pages:
     * 1. General intro
     * 2. Facebook login
     * 3. Name (default from Facebook)
     * 4. Phone Number (default from Facebook)
     * 5. Twitter
     * 6. Snapchat
     * 7. Done!
     */
    
    override func numberOfPages() -> Int {
        return 7
    }
}