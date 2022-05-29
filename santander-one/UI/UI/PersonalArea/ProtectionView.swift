//
//  Protection.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 14/01/2020.
//

import Foundation
import CoreFoundationLib

public final class ProtectionView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var imageIconClock: UIImageView!
    @IBOutlet private weak var imageView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var contentView: UIView!
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
    
    public func setViewModel(_ viewModel: SecurityViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title)
        self.subtitleLabel.isHidden = subtitleLabel.text?.isEmpty ?? false
        self.subtitleLabel.configureText(withKey: viewModel.subtitle, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.9))
        self.imageIcon.image = Assets.image(named: viewModel.icon)
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.button.accessibilityIdentifier = button
    }
}

// MARK: - Private Methods
private extension ProtectionView {
    @IBAction private func didTapOnProtection(_ sender: Any) {
        self.action?()
    }
    
    func setupView() {
        self.configureView()
        self.configureLabels()
        self.imageIconClock.image = Assets.image(named: "icnOneRed")
    }
    
    func configureView() {
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
    }
    
    func configureLabels() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        self.subtitleLabel.font = .santander(family: .text, type: .light, size: 12.0)
        self.subtitleLabel.textColor = .bostonRed
        self.subtitleLabel.numberOfLines = 0
    }
}
