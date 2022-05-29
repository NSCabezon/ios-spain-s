//
//  StoleCallViewController.swift
//  Alamofire
//
//  Created by Cristobal Ramos Laina on 15/01/2020.
//

import Foundation
import CoreFoundationLib

public protocol SinglePhoneViewDelegate: AnyObject {
    func didSelectSinglePhoneView(_ phoneNumber: String)
}

public final class SinglePhoneView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    public weak var delegate: SinglePhoneViewDelegate?
    private var phoneNumber: String?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    public func setViewModel(_ viewModel: PhoneViewModel) {
        self.phoneNumber = viewModel.phone
        self.numberLabel.text = phoneNumber
    }
    
    public func setViewModelWithoutNumberLabel(_ viewModel: PhoneViewModel) {
        self.phoneNumber = viewModel.phone
        if let title = viewModel.title, let titleLabel = titleLabel {
            titleLabel.numberOfLines = 0
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: titleLabel,
                                                     attribute: NSLayoutConstraint.Attribute.width,
                                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                                     toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                     multiplier: 1, constant: UIScreen.main.bounds.width / 3)
            titleLabel.superview?.addConstraints([widthConstraint])
            titleLabel.font = .santander(family: .text, type: .light, size: 11)
            titleLabel.configureText(withLocalizedString: title)
            numberLabel.isHidden = true
        }
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.button.accessibilityIdentifier = button
    }
}

private extension SinglePhoneView {
    @IBAction func didTapOnStoleCall(_ sender: Any) {
        guard let phoneNumber = phoneNumber else { return }
        delegate?.didSelectSinglePhoneView(phoneNumber)
    }
    
    func setupView() {
        self.frame = bounds
        self.backgroundColor = .darkTorquoise
        self.translatesAutoresizingMaskIntoConstraints = true
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.configureLabels()
    }
    
    func configureLabels() {
        titleLabel.textColor = .white
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        titleLabel.configureText(withKey: "manager_label_call")
        phoneImageView.image = Assets.image(named: "icnPhoneWhite")
        numberLabel.textColor = .white
        numberLabel.font = .santander(family: .text, type: .bold, size: 16.0)
    }
}
