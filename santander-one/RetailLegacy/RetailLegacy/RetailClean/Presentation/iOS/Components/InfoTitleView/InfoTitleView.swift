import UIKit

class InfoTitleView: UIView {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonInfo: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let style = LabelStylist(textColor: .uiWhite, font: .latoRegular(size: 20), textAlignment: .right)
        labelTitle.applyStyle(style)
        labelTitle.adjustsFontSizeToFitWidth = true
    }
}
