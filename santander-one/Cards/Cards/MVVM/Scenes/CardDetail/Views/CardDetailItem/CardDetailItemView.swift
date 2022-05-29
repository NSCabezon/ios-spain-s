import Foundation
import UI
import UIKit
import CoreFoundationLib

final class CardDetailItemView: XibView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setAccessibilityIdentifiers(identifier: String? = nil) {
        if let identifier = identifier {
            self.view?.accessibilityIdentifier = identifier + "_view"
            self.title.accessibilityIdentifier = identifier + "_title"
            self.value.accessibilityIdentifier = identifier + "_description"
        } else {
            self.view?.accessibilityIdentifier = AccessibilityCardDetail.cardDetailHeaderItem
            self.title.accessibilityIdentifier = AccessibilityCardDetail.cardDetailHeaderTitle
            self.value.accessibilityIdentifier = AccessibilityCardDetail.cardDetailHeaderDescription
        }
    }
}

private extension CardDetailItemView {
    func setupView() {
        self.view?.backgroundColor = .skyGray
        self.title.font = .santander(family: .text, type: .light, size: 16)
        self.title.textColor = .lisboaGray
        self.value.font = .santander(family: .text, type: .bold, size: 16)
        self.value.textColor = .lisboaGray
    }
}
