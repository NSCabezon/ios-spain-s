//
//  BottomSquareViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public final class BottomSquareView: XibView {
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var buttonBottom: UIButton!
    @IBOutlet private weak var alertLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
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
    
    public func setViewModel(_ viewModel: SecurityViewModel, existOffer: Bool) {
        if !existOffer {
            self.titleLabel.textColor = .lisboaGray
            self.titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
            self.titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
            self.alertLabel.font = .santander(family: .text, type: .regular, size: 16.0)
            self.alertLabel.configureText(withKey: viewModel.subtitle, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
            self.alertLabel.isHidden = false
            self.alertLabel.textColor = .darkTorquoise
            self.iconImage.image = Assets.image(named: viewModel.icon)
        } else {
            self.view?.isHidden = true
            self.buttonBottom.isEnabled = false
        }
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.buttonBottom.accessibilityIdentifier = button
    }
}

private extension BottomSquareView {
    @IBAction func didTapOnBottom(_ sender: Any) {
        self.action?()
    }
    
    func setAppearance() {
        self.view?.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
}
