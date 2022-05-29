//
//  EcommerceFooterWithTwoButtons.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 3/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public protocol DidTapInFooterWithTwoButtonsProtocol: class {
    func didTapInCancel()
    func didTapInBack()
    func didTapInRightButton(_ type: EcommerceFooterType)
}

public final class EcommerceFooterWithTwoButtons: XibView {
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var rightButtonContent: UIView!
    @IBOutlet private weak var rightButtonLabel: UILabel!
    @IBOutlet private weak var rightButtonImage: UIImageView!
    @IBOutlet private weak var rightButtonIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var rightTextBaseView: UIView!
    
    weak var delegate: DidTapInFooterWithTwoButtonsProtocol?
    private var type: EcommerceFooterType?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func config(_ footerType: EcommerceFooterType) {
        self.type = footerType
        switch self.type {
        case .restorePassword:
            self.setRightButtonPlainAppearance()
            self.cancelButton.setTitle(localized("ecommerce_button_back"), for: .normal)
        case .processingPayment:
            self.setRightButtonGrayAppearance()
            self.cancelButton.setTitle(localized("generic_button_cancel"), for: .normal)
        case .useCodeAccess:
            self.setRightButtonCodeAccesAppareance()
            self.cancelButton.setTitle(localized("ecommerce_button_back"), for: .normal)
        default:
            self.cancelButton.setTitle(localized("generic_button_cancel"), for: .normal)
        }
        self.setButtonWithImage(footerType)
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
        switch self.type {
        case .restorePassword:
            delegate?.didTapInBack()
        default:
            delegate?.didTapInCancel()
        }
    }
    
    @IBAction func didTapInRightButton(_ sender: Any) {
        guard let type = self.type else {
            return
        }
        delegate?.didTapInRightButton(type)
    }
}

private extension EcommerceFooterWithTwoButtons {
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
        self.rightButtonContent.backgroundColor = .darkTorquoise
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
    
    func setRightButtonGrayAppearance() {
        self.rightButtonContent.backgroundColor = .coolGray
    }
    
    func setRightButtonCodeAccesAppareance() {
        rightButtonLabel.configureText(withKey: "login_button_retrieveKey")
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
        self.cancelButton.accessibilityIdentifier = AccessibilityEcommerceFooterView.cancelButton
        self.rightButtonContent.accessibilityIdentifier = AccessibilityEcommerceFooterView.rightButton
    }
    
    // MARK: Right Button state config
    func setButtonWithImage(_ state: EcommerceFooterType) {
        let rightTitle = self.handleRightTitle(state)
        let rightImage = self.handleRightImage(state)
        if let text = rightTitle {
            rightButtonLabel.text = text.text
            if let image = rightImage {
                rightButtonImage.image = image.withRenderingMode(.alwaysTemplate)
                rightButtonImage.tintColor = .white
            } else {
                rightButtonImage.isHidden = true
            }
        }
    }
    
    func handleRightTitle(_ state: EcommerceFooterType) -> LocalizedStylableText? {
        var rightText: LocalizedStylableText?
        switch state {
        case .confirmBy(let type):
            if case .code = type {
                return localized("ecommerce_button_usePassword")
            }
            rightText = localized("generic_button_confirm")
        case .processingPayment:
            rightText = localized("ecommerce_button_identifying")
        case .restorePassword, .useCodeAccess:
            rightText = localized("login_button_retrieveKey")
        default:
            rightText = nil
        }
        return rightText
    }
    
    func handleRightImage(_ state: EcommerceFooterType) -> UIImage? {
        var rightImage: UIImage?
        showLoading(false)
        switch state {
        case .confirmBy(let type):
            switch type {
            case .code:
                rightImage = Assets.image(named: "icnBigAccessCode")
            case .faceId:
                rightImage = Assets.image(named: "icnEcommerceFaceIdWhiteSmall")
            case .fingerPrint:
                rightImage = Assets.image(named: "icnEcommerceTouchIdWhiteSmall")
            }
        case .processingPayment:
            rightImage = nil
            showLoading(true)
        default:
            rightImage = nil
        }
        return rightImage
    }
}
