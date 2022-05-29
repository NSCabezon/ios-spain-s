import Foundation
import UI
import UIKit
import CoreFoundationLib

final class CardDetailSubdataView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setup(with stackItems: [CardDetailTitle]) {
        stackView.removeAllArrangedSubviews()
        stackView.spacing = 2
        for item in stackItems {
            if stackView.arrangedSubviews.count > 0 {
                let separator = UIView()
                separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
                separator.backgroundColor = .mediumSky
                stackView.addArrangedSubview(separator)
                separator.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0).isActive = true
            }
            let cardDetailItem = CardDetailItemView()
            let itemTitleFont: UIFont = .santander(family: .text, type: .light, size: 14.0)
            let itemTitleConfiguration = LocalizedStylableTextConfiguration(font: itemTitleFont,
                                                                            alignment: .center,
                                                                            lineHeightMultiple: 0.75,
                                                                            lineBreakMode: .byWordWrapping)
            cardDetailItem.title.configureText(withKey: item.title,
                                               andConfiguration: itemTitleConfiguration)
            cardDetailItem.value.text = item.value
            cardDetailItem.setAccessibilityIdentifiers(identifier: item.title)
            stackView.addArrangedSubview(cardDetailItem)
            if let cardDetailFirstItem = stackView.arrangedSubviews.first as? CardDetailItemView {
                cardDetailItem.widthAnchor.constraint(equalTo: cardDetailFirstItem.widthAnchor).isActive = true
            }
        }
    }
}

private extension CardDetailSubdataView {
    func setupView() {
        self.view?.backgroundColor = .skyGray
    }
}
