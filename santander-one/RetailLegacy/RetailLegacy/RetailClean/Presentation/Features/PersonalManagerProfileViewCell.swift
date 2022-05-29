//

import UIKit

class PersonalManagerProfileViewCell: BaseViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var topSeparatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileName.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 21), textAlignment: .left))
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
}
