import UIKit
import RetailLegacy

class WidgetLineMessageRowView: UIView {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var fontColor: UIColor?
    
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
        messageLabel.textColor = fontColor
        messageLabel.font = UIFont.latoRegular(size: 12.0)
    }
    
    func setMessage(_ text: String) {
        setupViews()
        messageLabel.text = text
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        fontColor = fontColorMode
    }
}

extension WidgetLineMessageRowView: ViewCreatable {}
