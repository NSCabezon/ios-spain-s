import Foundation
import UI
import UIKit
import CoreFoundationLib
import OpenCombine

final class LoanDetailProductIconView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var shareImageView: UIImageView!
    let onTouchShareSubject = PassthroughSubject<Void, Never>()
    
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
                   valueIdentifier: String,
                   iconIdentifier: String) {
        self.titleLabel?.text = title
        self.valueLabel.text = value
        self.titleLabel.accessibilityIdentifier = titleIdentifier
        self.valueLabel.accessibilityIdentifier = valueIdentifier
        self.shareImageView.accessibilityIdentifier = iconIdentifier
    }
}

private extension LoanDetailProductIconView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .brownishGray
        self.valueLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.valueLabel.textColor = .lisboaGray
        self.shareImageView.image = Assets.image(named: "icnShareSlimGreen")
        self.imageShareTapped()
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityLoanDetail.detailView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityLoanDetail.titleDetail.rawValue
        self.valueLabel.accessibilityIdentifier = AccessibilityLoanDetail.subtitleDetail.rawValue
        self.shareImageView.accessibilityIdentifier = AccessibilityLoanDetail.shareIconDetail.rawValue
    }
    
    func imageShareTapped() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doShare(tapGestureRecognizer:)))
        self.shareImageView.isUserInteractionEnabled = true
        self.shareImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func doShare(tapGestureRecognizer: UITapGestureRecognizer) {
        self.onTouchShareSubject.send()
    }
}
