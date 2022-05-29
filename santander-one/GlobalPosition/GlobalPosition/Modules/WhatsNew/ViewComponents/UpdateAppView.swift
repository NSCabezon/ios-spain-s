//
//  UpdateAppView.swift
//  GlobalPosition
//
//  Created by Laura González on 06/07/2020.
//

import Foundation
import UI
import CoreFoundationLib

class UpdateAppView: DesignableView {
    @IBOutlet private weak var appImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var arrowImage: UIImageView!
    @IBOutlet private weak var container: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension UpdateAppView {
    func setupView() {
        appImage.image = Assets.image(named: "icnApp")
        arrowImage.image = Assets.image(named: "icnArrowRightSlimGreen8Pt")
        titleLabel.configureText(withKey: "whatsNew_label_notUpdated",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 14)))
        titleLabel.textColor = .lisboaGray
        subtitleLabel.configureText(withKey: "generic_button_updateTheApp",
                                    andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
        subtitleLabel.textColor = .darkTorquoise
        container.backgroundColor = .white
        let shadowConfiguration = ShadowConfiguration(color: UIColor.darkTorquoise.withAlphaComponent(0.33), opacity: 0.7, radius: 3.0, withOffset: 1, heightOffset: 2)
        self.container.drawRoundedBorderAndShadow(with: shadowConfiguration, cornerRadius: 6.0, borderColor: .lightSkyBlue, borderWith: 1.0)
        self.backgroundColor = .clear
    }
}
