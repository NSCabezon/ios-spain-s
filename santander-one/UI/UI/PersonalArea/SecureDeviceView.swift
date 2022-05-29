//
//  SecureDeviceView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 13/03/2020.
//

import Foundation
import CoreFoundationLib

public final class SecureDeviceView: XibView {
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var secureDeviceButton: UIButton!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    public var action: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }

    public func setViewModel(_ viewModel: SecurityViewModel) {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        self.titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.descriptionLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.descriptionLabel.configureText(withKey: viewModel.subtitle, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.descriptionLabel.textColor = .mediumSanGray
        self.iconImage.image = Assets.image(named: viewModel.icon)
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.secureDeviceButton.accessibilityIdentifier = button
    }
}

private extension SecureDeviceView {
    @IBAction func secureDeviceButtonPressed(_ sender: Any) {
        self.action?()
    }
    
    func setAppearance() {
        self.view?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
}
