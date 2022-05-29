import CoreFoundationLib

public protocol SecurityActionComponentsProtocol: AnyObject {
    func addPhone(_ action: SecurityActionType?) -> SecurityActionViewModelProtocol?
    func addMail(_ action: SecurityActionType?) -> SecurityActionViewModelProtocol?
    func addBiometrySystem(customAction: CustomAction?) -> SecurityActionViewModelProtocol?
    func addGeolocation() -> SecurityActionViewModelProtocol
    func addSecureDevice(_ state: ValidatedDeviceStateEntity,
                         _ offer: OfferEntity?) -> SecurityActionViewModelProtocol?
    func addUser(
        action: SecurityActionType,
        name: String,
        value: String,
        toolTip: String,
        externalAction: ExternalAction?
    ) -> SecurityActionViewModelProtocol
    func addCustom(
        action: SecurityActionType,
        name: String,
        value: String?,
        toolTip: String?,
        accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String]?,
        externalAction: ExternalAction?
    ) -> SecurityActionViewModelProtocol
    func addPasswordSignatureKey() -> SecurityActionViewModelProtocol
}

public final class SecurityActionComponents {
    private let userPreference: UserPrefWrapper
    
    public init(_ userPreference: UserPrefWrapper) {
        self.userPreference = userPreference
    }
    
    public func addPhone(_ action: SecurityActionType?) -> SecurityActionViewModelProtocol? {
        guard self.userPreference.isPersonalAreaEnabled == true else { return nil }
        let phoneNumber: String
        if let phone = self.userPreference.personalInfo?.maskedPhone, !phone.isEmpty {
            phoneNumber = phone
        } else {
            phoneNumber = localized("personalArea_text_uninformed")
        }
        let viewModel = SecurityActionViewModel(
            action: action,
            nameKey: "personalArea_label_telf",
            value: phoneNumber,
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.phoneContainer,
                .action: AccessibilitySecurityAreaAction.phoneAction,
                .value: AccessibilitySecurityAreaAction.phoneFilledValue
            ]
        )
        return viewModel
    }
    
    public func addMail(_ action: SecurityActionType?) -> SecurityActionViewModelProtocol? {
        guard self.userPreference.isPersonalAreaEnabled == true else { return nil }
        let email: String
        if let emailAddres = self.userPreference.personalInfo?.maskedEmail, !emailAddres.isEmpty {
            email =  emailAddres
        } else {
            email = localized("personalArea_text_uninformed")
        }
        let viewModel = SecurityActionViewModel(
            action: action,
            nameKey: "personalArea_label_mail",
            value: email,
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.mailContainer,
                .action: AccessibilitySecurityAreaAction.mailAction,
                .value: AccessibilitySecurityAreaAction.mailFilledValue
            ]
        )
        return viewModel
    }
    
    public func addBiometrySystem(customAction: CustomAction? = nil) -> SecurityActionViewModelProtocol? {
        guard let biometryType = userPreference.biometryType else { return nil }
        guard biometryType != .error(biometry: .none, error: .biometryNotAvailable) else { return nil }
        let biometryTypeText: String
        switch biometryType {
        case .faceId, .error(BiometryTypeEntity.faceId, _):
            biometryTypeText = "personalArea_label_faceId"
        case .touchId, .error(BiometryTypeEntity.touchId, _):
            biometryTypeText = "personalArea_label_touchId"
        case .error, .none:
            biometryTypeText = ""
        }
        let action: SecurityActionType?
        if customAction != nil {
            action = nil
        } else {
            action = .biometrySystem
        }
        let viewModel = SecuritySwitchViewModel(
            nameKey: biometryTypeText,
            switchState: self.userPreference.isAuthEnabled ?? false,
            action: action,
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.biometryContainer,
                .action: AccessibilitySecurityAreaAction.biometryAction
            ],
            customAction: customAction
        )
        return viewModel
    }
    
    public func addGeolocation() -> SecurityActionViewModelProtocol {
        let viewModel = SecuritySwitchViewModel(
            nameKey: "personalArea_label_geolocation",
            switchState: self.userPreference.isGeolocalizationEnabled ?? false,
            action: .geolocation,
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.locationContainer,
                .action: AccessibilitySecurityAreaAction.locationAction
            ]
        )
        return viewModel
    }
    
    public func addSecureDevice(_ state: ValidatedDeviceStateEntity,
                                _ offer: OfferEntity?) -> SecurityActionViewModelProtocol? {
        guard offer != nil else { return nil }
        let securityDeviceText: String = {
            switch state {
            case .anotherRegisteredDevice, .rightRegisteredDevice:
                return "security_label_configured"
            case .notRegisteredDevice:
                return "security_label_notConfigured"
            }
        }()
        let viewModel = SecurityActionViewModel(
            action: .secureDevice,
            nameKey: "personalArea_label_secureDevice",
            value: localized(securityDeviceText),
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.secureDeviceContainer,
                .action: AccessibilitySecurityAreaAction.secureDeviceAction,
                .value: AccessibilitySecurityAreaAction.secureDeviceFilledValue
            ]
        )
        return viewModel
    }
        
    public func addUser(action: SecurityActionType,
                        name: String,
                        value: String,
                        toolTip: String,
                        externalAction: ExternalAction?) -> SecurityActionViewModelProtocol {
        let viewModel = SecurityActionViewModel(
            action: action,
            nameKey: name,
            value: value,
            tooltipMessage: localized(toolTip),
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.operativityContainer,
                .action: AccessibilitySecurityAreaAction.operativityAction,
                .tooltip: AccessibilitySecurityAreaAction.operativityTooltipAction,
                .value: AccessibilitySecurityAreaAction.operativityFilledValue
            ],
            externalAction: externalAction
        )
        return viewModel
    }

    public func addCustom(action: SecurityActionType,
                        name: String,
                        value: String?,
                        toolTip: String?,
                        accessibilityIdentifiers: [SecurityActionAccessibilityIdentifierType: String]?,
                        externalAction: ExternalAction?) -> SecurityActionViewModelProtocol {
        let viewModel = SecurityActionViewModel(
            action: action,
            nameKey: name,
            value: value,
            tooltipMessage: toolTip,
            accessibilityIdentifiers: accessibilityIdentifiers ?? [:],
            externalAction: externalAction
        )
        return viewModel
    }

    public func addPasswordSignatureKey() -> SecurityActionViewModelProtocol {
        let viewModel = SecurityActionViewModel(
            action: .changePassword,
            nameKey: "personalArea_label_passwordSignatureKey",
            accessibilityIdentifiers: [
                .container: AccessibilitySecurityAreaAction.passwordContainer,
                .action: AccessibilitySecurityAreaAction.passwordAction
            ]
        )
        return viewModel
    }
}

extension SecurityActionComponents: SecurityActionComponentsProtocol { }
