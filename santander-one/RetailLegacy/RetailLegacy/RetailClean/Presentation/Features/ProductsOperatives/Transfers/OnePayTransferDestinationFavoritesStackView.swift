import UIKit

class OnePayTransferDestinationFavoritesStackView: StackItemView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    var valueAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .clear
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.sanRed.cgColor
        containerView.layer.borderWidth = 1
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoRegular(size: 15), textAlignment: .center))
        backgroundColor = .clear
    }
    
    func setTitle(text: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: text)
    }
    
    @IBAction func actionButton(_ sender: Any) {
        valueAction?()
    }
}
