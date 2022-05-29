import UIKit

class PersonalWithoutManagerTitleViewCell: BaseViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoHeavy(size: UIScreen.main.isIphone4or5 ? 24 : 31), textAlignment: .center))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: UIScreen.main.isIphone4or5 ? 13 : 16), textAlignment: .center))
        separator.backgroundColor = .lisboaGray
    }

}
