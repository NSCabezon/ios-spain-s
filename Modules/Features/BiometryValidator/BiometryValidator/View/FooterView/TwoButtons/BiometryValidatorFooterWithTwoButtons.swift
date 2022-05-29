//
//  BiometryValidatorFooterWithTwoButtons.swift
//  BiometryValidator
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol DidTapInFooterWithTwoButtonsProtocol: AnyObject {
    func didTapInCancel()
    func didTapInRightButton(status: BiometryValidatorStatus)
}

public final class BiometryValidatorFooterWithTwoButtons: XibView {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var rightButtonContent: UIView!
    @IBOutlet private weak var rightButtonLabel: UILabel!
    @IBOutlet private weak var rightButtonImage: UIImageView!
    @IBOutlet private weak var rightButtonIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var rightTextBaseView: UIView!
    
    // MARK: - Attributes

    weak var delegate: DidTapInFooterWithTwoButtonsProtocol?
    private var status: BiometryValidatorStatus = .confirm

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Methods
    
    func config(type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        self.status = status
        self.cancelButton.setTitle(localized("generic_button_cancel"), for: .normal)
        self.setButtonWithImage(type, status: status)
    }
    
    func showLoading(_ show: Bool) {
        self.rightButtonImage.isHidden = show
        self.rightButtonIndicator.isHidden = !show
        if show {
            self.rightButtonIndicator.startAnimating()
        } else {
            self.rightButtonIndicator.stopAnimating()
        }
    }
    
    @IBAction func didTapInCancelButton(_ sender: Any) {
        delegate?.didTapInCancel()
    }
    
    @IBAction func didTapInRightButton(_ sender: Any) {
        if self.status != .identifying {
            delegate?.didTapInRightButton(status: status)
        }
    }
}

private extension BiometryValidatorFooterWithTwoButtons {
    func setupView() {
        self.rightTextBaseView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.setRightButton()
        self.setCancelButton()
        self.setAccessibilityIds()
    }
    
    func setRightButton() {
        self.rightButtonLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.rightButtonLabel.textColor = .white
        self.rightButtonLabel.numberOfLines = 2
        self.rightButtonLabel.textAlignment = .left
        self.rightButtonLabel.lineBreakMode = .byTruncatingTail
        self.rightButtonLabel.set(lineHeightMultiple: 0.8)
        self.rightButtonImage.tintColor = .white
        self.rightButtonContent.backgroundColor = .bostonRed
        self.rightButtonContent.layer.cornerRadius = rightButtonContent.frame.size.height / 2
        self.rightButtonIndicator.isHidden = true
    }
    
    func setRightButtonPlainAppearance() {
        self.rightButtonLabel.font = UIFont.santander( size: 14)
        self.rightButtonLabel.textColor = .darkTorquoise
        self.rightButtonLabel.textAlignment = .right
        self.rightButtonContent.backgroundColor = .clear
        self.rightButtonImage.tintColor = .darkTorquoise
    }
    
    func setCancelButton() {
        self.cancelButton.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.cancelButton.setTitleColor(.darkTorquoise, for: .normal)
        self.cancelButton.backgroundColor = .clear
    }

    func setAccessibilityIds() {
        self.cancelButton.accessibilityIdentifier = AccessibilityBiometryValidatorFooterView.cancelButton
        self.rightButtonContent.accessibilityIdentifier = AccessibilityBiometryValidatorFooterView.rightButton
    }
    
    // MARK: Right Button state config
    func setButtonWithImage(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) {
        if let text = self.handleRightTitle(status) {
            rightButtonLabel.text = text.text
        }
        if let image = self.handleRightImage(type, status: status) {
            rightButtonImage.image = image.withRenderingMode(.alwaysTemplate)
            rightButtonImage.tintColor = .white
        } else {
            rightButtonImage.isHidden = true
        }
        switch status {
        case .confirm, .error:
            self.rightButtonContent.backgroundColor = .bostonRed
        case .identifying:
            self.rightButtonContent.backgroundColor = .brownGray
        }
    }
    
    func handleRightTitle(_ status: BiometryValidatorStatus) -> LocalizedStylableText? {
        var rightText: LocalizedStylableText?
        rightText = localized(status.titleText())
        return rightText
    }
    
    func handleRightImage(_ type: BiometryValidatorAuthType, status: BiometryValidatorStatus) -> UIImage? {
        var rightImage: UIImage?
        showLoading(false)
        switch status {
        case .confirm:
            rightImage = Assets.image(named: type.smallImageName())
        case .error:
            rightImage = Assets.image(named: "icnElectronicSignature")
        case .identifying:
            rightImage = nil
            self.rightButtonIndicator.isHidden = false
            showLoading(true)
        }
        return rightImage
    }
}
