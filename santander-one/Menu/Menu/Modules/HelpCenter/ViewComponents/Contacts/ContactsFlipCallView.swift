//
//  ContactsFlipCallView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 03/03/2020.
//

import Foundation
import CoreFoundationLib
import UI

public protocol ContactsFlipCallViewDelegate: AnyObject {
    func didSelectCall(_ phoneNumber: String)
}

public class ContactsFlipCallView: XibView {
    @IBOutlet private weak var phoneImage: UIImageView!
    @IBOutlet private weak var callNowLabel: UILabel!
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var arrowWhiteImage: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var containerView: UIView!
    private var phoneNumbers: [String]?
    public weak var delegate: ContactsFlipCallViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setModel(_ viewModel: ContactsFlipViewViewModel, phoneNumber: String?) {
        self.phoneNumbers = viewModel.phoneNumbers
        self.phoneImage.image = Assets.image(named: viewModel.icon)
        self.arrowWhiteImage.image = Assets.image(named: "icnArrowWhite")
        self.setAccessibilityIdentifiers(type: "\(viewModel.flipViewType)")
        guard let arrayPhoneNumbers = viewModel.phoneNumbers else {
            return
        }
        if arrayPhoneNumbers.count > 1 {
            self.callNowLabel.text = ""
            self.callNowLabel.isHidden = true
            self.arrowWhiteImage.isHidden = false
            self.numberLabel.textColor = .white
            self.numberLabel.font = .santander(family: .text, type: .bold, size: 20.0)
            if let phoneNumber = phoneNumber {
                self.numberLabel.text = phoneNumber
            }
            self.separatorView.isHidden = false
        } else {
            self.configureCallNowLabel(viewModel)
            self.arrowWhiteImage.isHidden = true
            if let phoneNumber = phoneNumber {
                self.numberLabel.text = phoneNumber
            }
            if viewModel.viewStyle == .showNumberLabel {
                self.numberLabel.textColor = .white
                self.numberLabel.font = .santander(family: .text, type: .bold, size: 20.0)
            } else {
                numberLabel.isHidden = true
            }
            self.separatorView.isHidden = true
        }
        setAppearance()
    }
    
    @IBAction func didTapOnCallNow(_ sender: Any) {
        if let phoneNumber = self.numberLabel.text {
            delegate?.didSelectCall(phoneNumber)
        }
    }
    
    private func setAccessibilityIdentifiers(type: String? = nil) {
        if let type = type {
            self.accessibilityIdentifier = "helpCenter_contactFlip_view_\(type)"
            callNowLabel.accessibilityIdentifier = "helpCenter_contactFlip_callNow_\(type)"
            numberLabel.accessibilityIdentifier = "helpCenter_contactFlip_number_\(type)"
        }
    }
}

private extension ContactsFlipCallView {
    func setAppearance() {
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureCallNowLabel(_ viewModel: ContactsFlipViewViewModel) {
        self.callNowLabel.isHidden = false
        if let titleKey = viewModel.extraLabel, let cell = callNowLabel {
            cell.configureText(withLocalizedString: titleKey)
        } else {
            let labelConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text,
                                                                                         type: .light,
                                                                                         size: 20.0))
            self.callNowLabel.configureText(withKey: "general_button_callNow",
                                            andConfiguration: labelConfiguration)
        }
    }
}
