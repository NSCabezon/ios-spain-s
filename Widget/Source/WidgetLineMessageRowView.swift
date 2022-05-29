import UIKit
import RetailLegacy

final class WidgetLineMessageRowView: UIView {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
        
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.font = UIFont.latoRegular(size: 12.0)
        setColors()
    }
    
    func setMessage(_ text: String) {
        setupViews()
        messageLabel.text = text
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
}

extension WidgetLineMessageRowView: ViewCreatable {}

private extension WidgetLineMessageRowView {
    func setColors() {
        messageLabel.textColor = fontColorMode
    }
}
