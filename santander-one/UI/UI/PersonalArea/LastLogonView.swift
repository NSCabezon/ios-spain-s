//
//  LastLogonView.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 07/08/2020.
//

import CoreFoundationLib

public final class LastLogonView: XibView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var lastAccessLabel: UILabel!
    @IBOutlet private weak var lastAccessDateLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setDate(with viewModel: LastLogonViewModel) {
        lastAccessDateLabel.text = viewModel.lastLogonDate
    }
}

// MARK: - Private Methods
private extension LastLogonView {
    
    func setupView() {
        [lastAccessLabel, lastAccessDateLabel].forEach { $0?.text = "" }
        roundView()
        configureFonts()
        configureLabelsForSmallDevices()
        iconImageView.image = Assets.image(named: "icnWatch")
        lastAccessLabel.configureText(
            withKey: "security_button_lastAccess",
            andConfiguration: LocalizedStylableTextConfiguration(
                font: UIFont.santander(family: .text, type: .light, size: 20),
                lineHeightMultiple: 0.8,
                lineBreakMode: .byTruncatingTail)
        )
        lastAccessLabel.numberOfLines = 2
        setAccesibilityIdentifiers()
    }
    
    func roundView() {
        self.view?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
    
    func configureFonts() {
        lastAccessDateLabel.font = UIFont.santander(family: .text, type: .regular, size: 16)
        lastAccessLabel.textColor = .lisboaGray
        lastAccessDateLabel.textColor = .darkTorquoise
    }

    func setAccesibilityIdentifiers() {
        iconImageView.accessibilityIdentifier = "icn_whatch"
        lastAccessLabel.accessibilityIdentifier = "security_button_lastAccess"
        lastAccessDateLabel.accessibilityIdentifier = "Date"
    }
    
    func configureLabelsForSmallDevices() {
        [lastAccessLabel, lastAccessDateLabel].forEach {
            $0?.minimumScaleFactor = 0.8
            $0?.adjustsFontSizeToFitWidth = true
        }
    }
}
