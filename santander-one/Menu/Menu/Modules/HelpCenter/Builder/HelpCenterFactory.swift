import CoreFoundationLib

public class HelpCenterFactory {
    public init() {}
    public func getHelpCenterEmergency(_ emergencyViewModel: HelpCenterEmergencyViewModel) -> [HelpCenterEmergencyItemViewModel] {
        let builder = HelpCenterBuilder()
        if let stolen = emergencyViewModel.stolen {
            builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized(stolen.title ?? ""), subtitle: localized(stolen.description ?? ""), icon: "icnStolenCard", action: .stolenCard(phoneNumber: stolen.phones, phonePos: nil), isPhoneView: true))
        }
        if emergencyViewModel.isFraudEnabled {
            builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_fraud"), icon: "icnThief2", action: .reportFraud, isPhoneView: true))
        }
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_signatureKey"), icon: "icnKeyLock", action: .blockSign))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_pin"), icon: "icnPin2", action: .pin))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_cvv"), icon: "oneIcnCvv", action: .cvv))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_needCash"), icon: "icnGetMoneyMobile2", action: .cash))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_sendMoney"), icon: "icnSendMoney2", action: .sendMoney))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_cancelTransfer"), icon: "icnCancelTransfer", action: .cancelTransfer))
        builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_changePassword"), icon: "icnChangeMagic", action: .changeMagic))
        if emergencyViewModel.isSuperlineEnabled {
            builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_superLine"), icon: "icnHelpCall2", action: .superlinea, isPhoneView: true))
        }
        if emergencyViewModel.isChatEnabled {
            builder.addImageLabel(viewModel: HelpCenterEmergencyItemViewModel(title: localized("helpCenter_button_chat"), icon: "icnHelpChat2", action: .chat))
        }
        return builder.build()
    }
}
