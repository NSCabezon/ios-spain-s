//
//  StoleViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public final class StoleView: XibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var phoneView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
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
        self.titleLabel.accessibilityIdentifier = "security_button_cardTheft"
        self.iconImageView.accessibilityIdentifier = "icnBlockCard"
        self.phoneImageView?.accessibilityIdentifier = "stoleImgicnCornerPhone"
    }
}

private extension StoleView {
    @IBAction private func stoleViewPressed(_ sender: Any) {
        self.action?()
    }
    
    func setupView() {
        self.configureLabels()
        self.setAppearance()
    }
    
    func setAppearance() {
        self.view?.frame = bounds
        self.view?.backgroundColor = .clear
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.phoneView.backgroundColor = .clear
    }
    
    func configureLabels() {
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(type: .light, size: 20.0)
        titleLabel.minimumScaleFactor = 0.5
        self.titleLabel.configureText(withKey: "security_button_cardTheft", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        iconImageView.image = Assets.image(named: "icnBlockCard")
        titleLabel.lineBreakMode = .byTruncatingTail
        phoneImageView?.image = Assets.image(named: "icnCornerPhone")
    }
}
