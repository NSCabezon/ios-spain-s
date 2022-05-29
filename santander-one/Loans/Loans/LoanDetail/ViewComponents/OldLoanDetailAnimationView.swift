import UIKit
import UI
import CoreFoundationLib

class OldLoanDetailAnimationView: XibView {
   
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var ticImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    func setSuccessAnimationView(subtitle: String) {
        self.subtitleLabel.isHidden = false
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "generic_label_perfect")
        self.ticImageView.image = Assets.image(named: "icnCheckToast")
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.subtitleLabel.textColor = .lisboaGray
        self.subtitleLabel.configureText(withKey: subtitle)
    }
    
    func setErrorAnimationView(title: String) {
        self.subtitleLabel.isHidden = true
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textColor = .bostonRed
        self.titleLabel.configureText(withKey: title)
        self.ticImageView.image = Assets.image(named: "icnAlertView")
    }
}

private extension OldLoanDetailAnimationView {
    func setAppearance() {
        self.drawShadow(offset: (x: 0, y: -2), opacity: 0.3, color: .lightSanGray, radius: 0)
        self.setAccesibilityIdentifers()
    }
    
    func setAccesibilityIdentifers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.copyTitle.rawValue
        self.subtitleLabel.isAccessibilityElement = true
        self.subtitleLabel.accessibilityIdentifier = AccessibilityIDLoanDetail.copySubtitle.rawValue
        self.ticImageView.accessibilityIdentifier = AccessibilityIDLoanDetail.copyIcon.rawValue
        self.view?.accessibilityIdentifier = AccessibilityIDLoanDetail.copyContainer.rawValue
    }
}
