//
//  WhatsNewWelcomeView.swift
//  GlobalPosition
//
//  Created by Laura González on 30/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class WhatsNewWelcomeView: DesignableView {
    
    @IBOutlet private weak var clockImage: UIImageView!
    @IBOutlet private weak var mainTitle: UILabel!
    @IBOutlet private weak var secondaryTitle: UILabel!
    @IBOutlet private weak var lastLoginInfo: UILabel!
    @IBOutlet private weak var secondaryLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var mainLabelHeight: NSLayoutConstraint!
    
    // MARK: - Public
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setViewModelData(_ viewModel: WhatsNewWelcomeViewModel?) {
        guard let viewModel = viewModel else { return }
        setMainTitle(viewModel)
        setSecondaryLabel(viewModel)
        setLastLoginInfo(viewModel)
    }
}

// MARK: - Private
private extension WhatsNewWelcomeView {
    func setupView() {
        self.backgroundColor = .clear
        self.setupLabels()
        self.setImage()
        self.setAccessibilityIdentifiers()
    }
    
    func setMainTitle(_ viewModel: WhatsNewWelcomeViewModel) {
        mainLabelHeight.constant = viewModel.mainTitleHeight
        mainTitle.configureText(withLocalizedString: viewModel.mainTitleText)
        if viewModel.showSecondaryTitle {
            mainTitle.font = UIFont.santander(family: .text, type: .bold, size: 16)
        }
    }
    
    func setSecondaryLabel(_ viewModel: WhatsNewWelcomeViewModel) {
        secondaryLabelHeight.constant = viewModel.secondaryTitleHeight
        
        if viewModel.showSecondaryTitle {
            secondaryTitle.configureText(withKey: "whatsNew_text_withoutEnteringFrom")
        } else {
            secondaryTitle.isHidden = true
        }
    }
    
    func setLastLoginInfo(_ viewModel: WhatsNewWelcomeViewModel) {
        lastLoginInfo.configureText(withLocalizedString: viewModel.lastSessionText)
    }
    
    func setupLabels() {
        mainTitle.font = UIFont.santander(family: .text, type: .regular, size: 16)
        mainTitle.textColor = .lisboaGray
        mainTitle.lineBreakMode = .byWordWrapping
        mainTitle.numberOfLines = 2
        mainTitle.adjustsFontSizeToFitWidth = true
        
        secondaryTitle.font = .santander(family: .text, type: .regular, size: 14)
        secondaryTitle.textColor = .lisboaGray
        secondaryTitle.lineBreakMode = .byWordWrapping
        secondaryTitle.numberOfLines = 2
        
        lastLoginInfo.font = UIFont.santander(family: .text, type: .regular, size: 14)
        lastLoginInfo.textColor = .mediumSanGray
    }
    
    func setImage() {
        clockImage.image = Assets.image(named: "icnSpeakerBlue")
        clockImage.tintColor = .darkTorquoise
    }
    
    func setAccessibilityIdentifiers() {
        self.mainTitle.accessibilityIdentifier = "whatsNew_title_withoutEnteringFrom"
        self.secondaryTitle.accessibilityIdentifier = "whatsNew_text_withoutEnteringFrom"
        self.clockImage.accessibilityIdentifier = "icnSpeakerBlue"
    }
}
