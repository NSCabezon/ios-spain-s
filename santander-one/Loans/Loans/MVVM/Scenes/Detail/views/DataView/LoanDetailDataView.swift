import Foundation
import UI
import UIKit
import CoreFoundationLib
import CoreDomain
import OpenCombine

final class LoanDetailDataView: XibView {
    
    @IBOutlet private weak var loanNameLabel: UILabel!
    @IBOutlet private weak var displayNumberLabel: UILabel!
    @IBOutlet private weak var copyIconDisplayNumberImageView: UIImageView!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var amountBalanceLabel: UILabel!
    let onTouchCopySubject = PassthroughSubject<Void, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configure(loan: LoanRepresentable) {
        self.loanNameLabel?.text = loan.alias?.camelCasedString ?? ""
        self.displayNumberLabel?.text = loan.contractDisplayNumber
        self.amountBalanceLabel?.attributedText = loan.availableBigAmountAttributedString
        self.enableCopyTap()
    }
    
    func enableCopyTap() {
        self.copyIconDisplayNumberImageView.isUserInteractionEnabled = true
    }
}

private extension LoanDetailDataView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.loanNameLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.loanNameLabel.textColor = .lisboaGray
        self.displayNumberLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.displayNumberLabel.textColor = .grafite
        self.balanceLabel.font = .santander(family: .text, type: .regular, size: 13)
        self.balanceLabel.textColor = .grafite
        self.balanceLabel?.configureText(withKey: "loansOption_label_pending")
        self.amountBalanceLabel.font = .santander(family: .text, type: .bold, size: 36)
        self.amountBalanceLabel.textColor = .lisboaGray
        self.copyIconDisplayNumberImageView.image = Assets.image(named: "icnCopyGreen")
        self.drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1)
        self.imageTap()
        self.setAccessibilityIdentifiers()
    }
        
    func imageTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyDisplayNumber(tapGestureRecognizer:)))
        self.copyIconDisplayNumberImageView.isUserInteractionEnabled = true
        self.copyIconDisplayNumberImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func copyDisplayNumber(tapGestureRecognizer: UITapGestureRecognizer) {
        UIPasteboard.general.string = self.displayNumberLabel?.text
        self.copyIconDisplayNumberImageView.isUserInteractionEnabled = false
        self.onTouchCopySubject.send()
    }
    
    func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilityIDLoanDetail.itemContainer.rawValue
        self.loanNameLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.itemAlias.rawValue
        self.displayNumberLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.itemContract.rawValue
        self.copyIconDisplayNumberImageView.accessibilityIdentifier = AccessibilityIDLoanDetail.itemCopyIcon.rawValue
        self.balanceLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.itemStatus.rawValue
        self.amountBalanceLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.itemAmount.rawValue
    }
}
