//
//  PermissionsViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public final class PermissionsView: XibView {
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var button: UIButton!
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
    }
}

private extension PermissionsView {
    @IBAction func didTapOnPermissions(_ sender: Any) {
        self.action?()
    }
    
    func setupView() {
        self.configureLabels()
        self.setAppearance()
    }
    
    func configureLabels() {
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .light, size: 18.0)
        titleLabel.configureText(withKey: "security_button_permissions", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        titleLabel.lineBreakMode = .byTruncatingTail
        iconImageView.image = Assets.image(named: "icnArrowPhone")
    }
    
    func setAppearance() {
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view?.backgroundColor = .white
        self.view?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
}
