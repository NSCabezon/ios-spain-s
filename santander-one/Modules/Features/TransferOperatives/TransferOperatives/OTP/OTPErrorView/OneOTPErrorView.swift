//
//  OneOTPErrorView.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 17/12/21.
//

import UI
import UIOneComponents
import CoreFoundationLib
import Operative
import UIKit

struct OneOTPErrorViewModel {
    typealias ErrorAction = (key: String, action: () -> Void)
    var imagenKey: String? = nil
    var imageColor: UIColor = .oneLisboaGray
    let titleKey: String
    let subtitleKey: String
    var phone: String? = nil
    var action: ErrorAction?
    var isDissmissable: Bool = true
}

struct OneOTPErrorFactory {
    private var viewModel: OneOTPErrorViewModel?
    private var supportPhone: String?
    
    init(dialogType: OTPDialogType, supportPhone: String?) {
        self.supportPhone = supportPhone
        let viewModel: OneOTPErrorViewModel
        switch dialogType {
        case .expired(let action): viewModel = self.createExpiredViewModel(action: action)
        case .wrongOTP: viewModel = self.createWrongOtpViewModel()
        case .revoked(let action): viewModel = self.createRevokedViewModel(action: action)
        case .genenic(let type): viewModel = self.createGenericViewModel(type: type)
        default: viewModel = self.createDefaultViewModel()
        }
        self.viewModel = viewModel
    }
    
    func build() -> OneOTPErrorViewModel {
        guard let viewModel = self.viewModel else {
            return self.createDefaultViewModel()
        }
        return viewModel
    }
}

private extension OneOTPErrorFactory {
    func createExpiredViewModel(action: @escaping () -> Void) -> OneOTPErrorViewModel {
        return OneOTPErrorViewModel(imagenKey: "oneIcnClock",
                                    titleKey: "otp_titleAlert_expiredCode",
                                    subtitleKey: "otp_alert_expiredCode",
                                    action: (key: "otp_button_backConfirm", action: action),
                                    isDissmissable: false)
    }
    
    func createWrongOtpViewModel() -> OneOTPErrorViewModel {
        return OneOTPErrorViewModel(imagenKey: "oneIcnAlert",
                                    imageColor: .oneBostonRed,
                                    titleKey: "otp_titlePopup_error",
                                    subtitleKey: "otp_text_popup_error",
                                    action: (key: "otp_button_accept", action: {}))
    }
    
    func createRevokedViewModel(action: @escaping () -> Void) -> OneOTPErrorViewModel {
        return OneOTPErrorViewModel(imagenKey: "oneIcnAlert",
                                    imageColor: .oneBostonRed,
                                    titleKey: "otpSCA_alert_title_blocked",
                                    subtitleKey: "otpSCA_alert_text_blocked",
                                    action: (key: "otp_button_goSendMoney", action),
                                    isDissmissable: false)
    }
    
    func createGenericViewModel(type: OTPDialogType.OTPGenericType) -> OneOTPErrorViewModel {
        switch type {
        case .genericOTPDialog:
            var subtitleKey = "otp_alert_retry"
            var phoneText: String?
            if let phone = self.supportPhone {
                subtitleKey = "otp_text_popup_notReceived"
                phoneText = phone
            }
            return OneOTPErrorViewModel(titleKey: "otp_titlePopup_notReceived",
                                        subtitleKey: subtitleKey,
                                        phone: phoneText,
                                        action: (key: "generic_button_understand", action: {}))
        case .notRegisteredDeviceDialog:
            return OneOTPErrorViewModel(titleKey: "otp_titlePopup_notReceived",
                                        subtitleKey: "otp_text_notReceived_otherDevice",
                                        action: (key: "generic_button_understand", action: {}))
        }
    }
    
    func createDefaultViewModel() -> OneOTPErrorViewModel {
        return OneOTPErrorViewModel(imagenKey: "oneIcnInputClose",
                                    titleKey: "otp_title_error_unsuccessful",
                                    subtitleKey: "otp_text_error_unsuccessful",
                                    action: (key: "otp_button_accept", action: {}))
    }
}

protocol OneOTPErrorViewDelegate: AnyObject {
    func oneOTPErrorViewDidTapAccept(viewController: UIViewController?, action: (() -> Void)?, shouldDissmiss: Bool)
}

final class OneOTPErrorView: XibView {
    weak var delegate: OneOTPErrorViewDelegate?
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var oneFloatingButton: OneFloatingButton!
    private var action: (() -> Void)?
    private var shouldDissmiss: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    func setupViewModel(_ viewModel: OneOTPErrorViewModel) {
        self.titleLabel.configureText(withKey: viewModel.titleKey)
        if let phone = viewModel.phone {
            let text = localized(viewModel.subtitleKey, [StringPlaceholder(.phone, phone)])
            self.subtitleLabel.configureText(withLocalizedString: text)
        } else {
            self.subtitleLabel.configureText(withKey: viewModel.subtitleKey)
        }
        self.action = viewModel.action?.action
        self.configureActionButton(viewModel: viewModel)
        guard let imageKey = viewModel.imagenKey,
              let image = Assets.image(named: imageKey)?.withRenderingMode(.alwaysTemplate)
        else {
            self.imageView.removeFromSuperview()
            return
        }
        self.imageView.image = image
        self.imageView.tintColor = viewModel.imageColor
    }
    
    @IBAction private func didTapOnConfirm(_ sender: OneFloatingButton) {
        let vc = self.parentContainerViewController()
        self.delegate?.oneOTPErrorViewDidTapAccept(viewController: vc, action: self.action, shouldDissmiss: self.shouldDissmiss)
    }
}

private extension OneOTPErrorView {
    func setupViews() {
        self.titleLabel.font = .typography(fontName: .oneH300Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB400Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func configureActionButton(viewModel: OneOTPErrorViewModel) {
        self.oneFloatingButton.configureWith(type: .primary,
                                             size: .medium(
                                                OneFloatingButton.ButtonSize.MediumButtonConfig(title: viewModel.action?.key ?? "",
                                                                                                icons: .none,
                                                                                                fullWidth: true)
                                             ),
                                             status: .ready)
    }
    
    func setupAccessibilityIdentifiers(viewModel: OneOTPErrorViewModel) {
        self.imageView.accessibilityIdentifier = viewModel.imagenKey
        self.titleLabel.accessibilityIdentifier = viewModel.titleKey
        self.subtitleLabel.accessibilityIdentifier = viewModel.subtitleKey
        self.oneFloatingButton.accessibilityIdentifier = viewModel.action?.key
    }
}
