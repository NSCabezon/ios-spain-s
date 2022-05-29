import Foundation
import UI
import UIKit
import CoreFoundationLib

final class CardProductDetailBasicView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupViewModel(title: CardDetailTitle, type: CardDetailDataType) {
        self.titleLabel?.text = title.title
        self.valueLabel.text = title.value
        self.setAccessibilityIdentifiers(type: type)
    }
}

private extension CardProductDetailBasicView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIdentifiers(type: CardDetailDataType) {
        self.view?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailListItem + "_\(type)"
        self.titleLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailActionItemTitle + "_\(type)"
        self.valueLabel.accessibilityIdentifier = AccessibilityCardDetail.cardDetailActionItemDescription + "_\(type)"
        
    }
}
