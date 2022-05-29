import UIKit
import UI

class SummaryFooterItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageview: UIImageView!
    var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        titleLabel.textColor = UIColor.white
    }
    
    @IBAction func touchItem() {
        action?()
    }
}
