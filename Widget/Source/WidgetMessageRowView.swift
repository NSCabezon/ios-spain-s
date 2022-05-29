import UIKit
import RetailLegacy

final class WidgetMessageRowView: UIView {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var fontColor: UIColor?
    
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium
        messageLabel.font = UIFont.latoRegular(size: 12.0)
        setColors()
    }
    
    func setMessage(_ text: String?) {
        setupViews()
        messageLabel.text = text
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
}

extension WidgetMessageRowView: ViewCreatable {}
private extension WidgetMessageRowView {
    func setColors() {
        messageLabel.textColor = fontColorMode
    }
}
