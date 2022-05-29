import UIKit

class PersonalManagerRequirementViewCell: BaseViewCell {
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var requirementLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dotView.layer.cornerRadius = dotView.frame.size.height / 2
        requirementLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .natural))
        backgroundColor = .uiWhite
    }
    
}
