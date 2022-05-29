import CoreFoundationLib
import UIKit
import UI

final class AviosUnavailableDataLabelView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lisboaGray
        label.configureText(
            withKey: "avios_text_error",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: .santander(family: .text, type: .regular, size: 16),
                alignment: .center,
                lineBreakMode: .byWordWrapping
            )
        )
        label.accessibilityIdentifier = "avios_text_error"
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.topAnchor.constraint(equalTo: label.topAnchor, constant: -21).isActive = true
        self.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 21).isActive = true
        self.leftAnchor.constraint(equalTo: label.leftAnchor, constant: -45).isActive = true
        self.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 45).isActive = true
    }
}
