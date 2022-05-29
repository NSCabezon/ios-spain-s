//

import UIKit
import UI
import CoreFoundationLib

protocol BottomActionsOnboardingViewDelegate: class {
    func backPressed()
    func continuePressed()
}

class BottomActionsOnboardingView: UIView, ViewCreatable {
    weak var delegate: BottomActionsOnboardingViewDelegate?
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet weak var continueButton: WhiteLisboaButton!
    @IBOutlet weak var finishButton: RedLisboaButton!
    @IBOutlet private weak var topSeparatorView: UIView!
    
    var continueText: LocalizedStylableText? {
        didSet {
            if let text = continueText {
                self.continueButton.set(localizedStylableText: text, state: .normal)
                self.finishButton.set(localizedStylableText: text, state: .normal)
                self.finishButton.titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }
    var backText: LocalizedStylableText? {
        didSet {
            if let text = self.backText {
                self.backButton.set(localizedStylableText: text, state: .normal)
                self.backButton.adjustTextIntoButton()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupViews(_ isRed: Bool = false) {
        self.backButton.setImage(Assets.image(named: "icnArrowLeftRedNew"), for: .normal)
        self.backButton.tintColor = .santanderRed
        let styleButton = ButtonStylist(textColor: .santanderRed, font: .santanderTextRegular(size: 14))
        self.backButton.applyStyle(styleButton)
        self.topSeparatorView.backgroundColor = .mediumSkyGray
        if isRed {
            self.continueButton.isHidden = true
        } else {
            self.finishButton.isHidden = true
        }
        self.continueButton.addSelectorAction(target: self, #selector(self.clickContinueButton))
        self.finishButton.addSelectorAction(target: self, #selector(self.clickContinueButton))
        self.setAccesibilityIdentifiers()
    }
  
    func setAccesibilityIdentifiers() {
        self.finishButton.accessibilityIdentifier = AccessibilityOnboardingOptions.finishButton
        self.finishButton.titleLabel?.accessibilityIdentifier = AccessibilityOnboardingOptions.finishButtonLabel
        self.continueButton.accessibilityIdentifier = AccessibilityOnboardingOptions.continueButton
    }
        
    @IBAction func clickBackButton(_ sender: Any) {
        self.delegate?.backPressed()
    }
    
    @objc func clickContinueButton(_ gesture: UITapGestureRecognizer) {
        self.delegate?.continuePressed()
    }
}
