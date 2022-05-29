//
//  ReportFraudViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public final class ReportFraudView: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var phoneView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var reportLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    public var action: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.button.accessibilityIdentifier = button
        self.titleLabel.accessibilityIdentifier = "security_button_fraud"
        self.reportLabel.accessibilityIdentifier = "security_text_fraud"
        self.iconImageView.accessibilityIdentifier = "icnHackersBig"
        self.phoneImageView.accessibilityIdentifier = "reportFraudImgicnCornerPhone"
    }
}

private extension ReportFraudView {
    @IBAction func reportFraudViewPressed(_ sender: Any) {
        self.action?()
    }
    
    func setupView() {
        self.configureLabels()
        self.setAppearance()
    }
    
    func configureLabels() {
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        titleLabel.configureText(withKey: "security_button_fraud", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        reportLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        reportLabel.configureText(withKey: "security_text_fraud", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        reportLabel.textColor = .mediumSanGray
        reportLabel.lineBreakMode = .byTruncatingTail
        iconImageView.image = Assets.image(named: "icnHackersBig")
        phoneImageView.image = Assets.image(named: "icnCornerPhone")
    }
    
    func setAppearance() {
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view?.backgroundColor = .clear
        self.contentView.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.phoneView.backgroundColor = .clear
    }
}
