import Foundation
import UI
import UIKit
import CoreFoundationLib

final class LoanDetailProductBasicView: XibView {
    
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
    
    func configure(title: String,
                   value: String,
                   titleIdentifier: String,
                   valueIdentifier: String) {
        self.titleLabel?.text = title
        self.valueLabel.text = value
        self.titleLabel.accessibilityIdentifier = titleIdentifier
        self.valueLabel.accessibilityIdentifier = valueIdentifier
    }
}

private extension LoanDetailProductBasicView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityLoanDetail.detailView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityLoanDetail.titleDetail.rawValue
        self.valueLabel.accessibilityIdentifier = AccessibilityLoanDetail.subtitleDetail.rawValue
    }
}
