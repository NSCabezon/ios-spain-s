import UIKit
import UI

class SummaryHeaderItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 13)
        titleLabel.textColor = UIColor(red: 123.0 / 255.0, green: 130.0 / 255.0, blue: 132.0 / 255.0, alpha: 1.0)
        subtitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        subtitleLabel.textColor = UIColor(red: 77.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
}
