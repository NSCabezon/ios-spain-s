import UIKit

class GenericOperativeHeaderTwoLineView: BaseHeader, ViewCreatable {    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 14), textAlignment: .left))
        amountLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .left))
        infoLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoRegular(size: 14), textAlignment: .left))
    }
}
