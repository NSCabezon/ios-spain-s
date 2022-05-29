//

import UIKit
import UI

class ItemTableViewCell: BaseViewCell {

    @IBOutlet weak var separatorView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lisboaGray
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: 16.0), textAlignment: .left))
        arrowImage.image = Assets.image(named: "icnArrowRightSmall")
    }
}
