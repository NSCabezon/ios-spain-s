//
//  Travel.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public final class TravelView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
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
    }
}

private extension TravelView {
    @IBAction func didTapOnTravel(_ sender: Any) {
        self.action?()
    }
    
    func setupView() {
        self.configureLabels()
        self.setAppearance()
    }
    
    func configureLabels() {
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        titleLabel.configureText(withKey: "security_button_travelMode", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        subtitleLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        subtitleLabel.configureText(withKey: "security_text_travelMode", andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        subtitleLabel.textColor = .mediumSanGray
        subtitleLabel.lineBreakMode = .byTruncatingTail
        iconImageView.image = Assets.image(named: "icnParachute")
    }
    
    func setAppearance() {
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.white
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
}
