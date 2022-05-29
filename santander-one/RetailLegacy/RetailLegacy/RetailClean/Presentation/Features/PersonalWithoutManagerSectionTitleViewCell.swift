//

import UIKit

class PersonalWithoutManagerSectionTitleViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoHeavy(size: 16), textAlignment: .left))
    }
    
}
