import UIKit

class GenericOperativeHeaderOneLineView: BaseHeader, ViewCreatable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountlabel: UILabel!
    @IBOutlet weak var contentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: UIFont.latoMedium(size: 16), textAlignment: .left))
        amountlabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .right))
    }
}
