//
//  SKFirstScreenKnowMore.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 8/2/22.
//

import UIKit
import UI
import CoreFoundationLib

public final class SKFirstScreenKnowMore: XibView {
    
    @IBOutlet private weak var firstTitleLabel: UILabel!
    @IBOutlet private weak var firstDescriptionLabel: UILabel!
    @IBOutlet private weak var secondTitleLabel: UILabel!
    @IBOutlet private weak var secondDescriptionLabel: UILabel!
    @IBOutlet private weak var thirdTitleLabel: UILabel!
    @IBOutlet private weak var thirdDescriptionLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
}

private extension SKFirstScreenKnowMore {
    func setupView() {
        firstTitleLabel.configureText(withKey: "sanKey_title_whatIs", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 18), alignment: .left))
        firstTitleLabel.textColor = .lisboaGray
        firstTitleLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.firstTitleLabel
        firstDescriptionLabel.configureText(withKey: "sanKey_text_whatIs", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14), alignment: .left))
        firstDescriptionLabel.textColor = .lisboaGray
        firstDescriptionLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.firstDescriptionLabel
        secondTitleLabel.configureText(withKey: "sanKey_title_whatIsBiometrics", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 18), alignment: .left))
        secondTitleLabel.textColor = .lisboaGray
        secondTitleLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.secondTitleLabel
        secondDescriptionLabel.configureText(withKey: "sanKey_text_whatIsBiometrics", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14), alignment: .left))
        secondDescriptionLabel.textColor = .lisboaGray
        secondDescriptionLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.secondDescriptionLabel
        thirdTitleLabel.configureText(withKey: "sanKey_title_multichannelSignature", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 18), alignment: .left))
        thirdTitleLabel.textColor = .lisboaGray
        thirdTitleLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.thirdTitleLabel
        thirdDescriptionLabel.configureText(withKey: "sanKey_text_multichannelSignature", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14), alignment: .left))
        thirdDescriptionLabel.textColor = .lisboaGray
        thirdDescriptionLabel.accessibilityIdentifier = AccessibilitySkFirstStepOnboarding.KnowMoreView.thirdDescriptionLabel
    }
}
