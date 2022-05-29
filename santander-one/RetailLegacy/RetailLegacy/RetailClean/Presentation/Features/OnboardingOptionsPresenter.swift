import UIKit
import CoreFoundationLib

final class OnboardingOptionsPresenter: BaseOnboardingPresenter<OnboardingOptionsViewController, OnboardingNavigator, OnboardingOptionsProtocol> {
    
    private var localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    private var authViewModel: AuthOptionOnboardingViewModel?
    private var pushNotificationsViewModel: PushNotificationsOptionOnboardingViewModel?
    private var geoLocationViewModel: LocalizationOptionOnboardingViewModel?
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependencies.localAppConfig
    }
    
    init(localAuthentication: LocalAuthenticationPermissionsManagerProtocol, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OnboardingNavigatorProtocol) {
        self.localAuthentication = localAuthentication
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    private var isBiometryAvailable: Bool {
        if case .error = localAuthentication.biometryTypeAvailable {
            return false
        } else if case .none = localAuthentication.biometryTypeAvailable {
            return false
        }
        return true
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        reloadSections()
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingOptions().page
    }
    
    func authSwitchValueChanged(inViewModel viewModel: AuthOptionOnboardingViewModel) {
        guard validateUserLoginType() || viewModel.switchState == false else {
            viewModel.switchState = false
            reloadData()
            return showInvalidUserLoginTypeMessage(localAuthentication.biometryTypeAvailable)
        }
        if viewModel.switchState {
            askBiometryIfNoEnabled(viewModel: viewModel) { [weak self] enabled in
                if enabled { self?.showBiometryAlert(for: .enabled) }
            }
        } else if !isBiometryAvailable {
            /// You can get in this situation by holding your finger down while switching when you cannot activate widget.
            viewModel.switchState = false
        } else {
            disableBiometricPermissions(viewModel) { [weak self] in
                self?.showBiometryAlert(for: .disabled)
            }
        }
    }
    
    func notificationsSwitchValueChanged(inViewModel viewModel: PushNotificationsOptionOnboardingViewModel) {
        viewModel.hideLoading()
        guard let permissionsManager = notificationPermissionsManager else { return }
        viewModel.showLoading()
        permissionsManager.isAlreadySet { [weak self] isAlreadySet in
            guard let self = self else { return }
            if isAlreadySet {
                DispatchQueue.main.async {
                    viewModel.hideLoading()
                    let completion = { [weak self] () in
                        guard let self = self else { return }
                        self.navigator.navigateToSettings()
                    }
                    let acceptComponents = DialogButtonComponents(titled: self.localized(key: "genericAlert_buttom_settings"), does: completion)
                    let cancelComponents = DialogButtonComponents(titled: self.localized(key: "generic_button_cancel"), does: nil)
                    Dialog.alert(title: nil, body: self.localized(key: "onboarding_alert_text_permissionActivation"), withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: self.view)
                }
            } else {
                self.trackEvent(eventId: OnboardingOptions.Action.notifications.rawValue, parameters: [:])
                permissionsManager.requestAccess { [weak self] _ in
                    viewModel.hideLoading()
                    self?.reloadData()
                }
            }
        }
    }
    
    func geoLocationSwitchValueChanged(inViewModel viewModel: LocalizationOptionOnboardingViewModel) {
        viewModel.hideLoading()
        guard viewModel.switchState == true else {
            showNativeLocationPermissions()
            return
        }
        if self.localAppConfig.isEnabledOnboardingLocationDialog {
            showLisboaLocationPermissionsDialog(acceptAction: { [weak self] in
                self?.showNativeLocationPermissions()
            }, cancelAction: { [weak self] in
                viewModel.switchState = false
                self?.reloadData()
            })
        } else {
            self.showNativeLocationPermissions()
        }
    }
}

extension OnboardingOptionsPresenter: SiriIntentsOperator {}

extension OnboardingOptionsPresenter: OnboardingPresenterProtocol {
    func goBack() {
        navigator.goBack()
    }
    
    func goContinue() {
        navigator.next()
    }
}

extension OnboardingOptionsPresenter: OnboardingOptionsProtocol {
    func enterFromBackground() {
        reloadData()
    }
}

// MARK: -  Private Methods
private extension OnboardingOptionsPresenter {
    
    func reloadSections() {
        guard let permissions: [FirstBoardingPermissionTypeItem] = onboardingUserData?.items else {
            return
        }
        var sectionsInfo: [StackSection] = []
        for permission in permissions {
            let firstPermission = permission.1.first ?? false
            switch permission.0 {
            case .touchId:
                guard let authModel = addAuthSection(keychainBiometryEnabled: firstPermission) else { return }
                if self.isBiometryAvailable {
                    let section = StackSection()
                    section.add(item: authModel)
                    sectionsInfo.append(section)
                }
            case .notifications(title: let title):
                guard let pushModel = addPushNotificationsSection(pushNotificationsActive: firstPermission, title: title) else { return }
                let section = StackSection()
                section.add(item: pushModel)
                sectionsInfo.append(section)
            case .location(title: let title):
                guard let geoLocationModel = addGeoLocationSection(locationActive: firstPermission, title: title) else { return }
                let section = StackSection()
                section.add(item: geoLocationModel)
                sectionsInfo.append(section)
            case .custom(options: let options):
                let viewModel: CustomOptionOnboardingViewModel = self.getCustomOption(options)
                let section = StackSection()
                section.add(item: viewModel)
                sectionsInfo.append(section)
            case .customWithTooltip(options: let options):
                let viewModel: CustomOptionWithTooltipOnboardingViewModel = self.getCustomOption(options)
                let section = StackSection()
                section.add(item: viewModel)
                sectionsInfo.append(section)
            }
        }
        view.dataSource.reloadSections(sections: sectionsInfo)
    }
    
    func getCustomOption(_ options: CustomOptionOnbarding) -> CustomOptionOnboardingViewModel {
        let optionViewModel = CustomOptionOnboardingViewModel(stringLoader: self.stringLoader,
                                                        titleKey: options.titleKey,
                                                        descriptionKey: options.textKey,
                                                        imageName: options.imageName,
                                                        switchText: options.switchText,
                                                        switchState: options.isEnabled()) { _ in
            options.action { [weak self] reload in
                if reload {
                    self?.reloadSections()
                }
            }
        }
        return optionViewModel
    }
    
    func getCustomOption(_ options: CustomOptionWithTooltipOnbarding) -> CustomOptionWithTooltipOnboardingViewModel {
        let cellViewModels = options.cell.map {
            CustomOptionWithTooltipOnboardingCellViewModel(
                content: $0,
                iconName: $0.iconName,
                iconTextKey: $0.iconTextKey,
                tooltipKey: $0.tooltipKey,
                tooltipImage: $0.tooltipImage,
                separatorViewVisible: (options.cell.endIndex != 0),
                switchState: $0.isEnabled(),
                presenter: self) }
        let optionViewModel = CustomOptionWithTooltipOnboardingViewModel(
            stringLoader: self.stringLoader,
            titleKey: options.titleKey,
            descriptionKey: options.textKey,
            imageName: options.imageName,
            cellViewModel: cellViewModels) { cell in
            cell.action { [weak self] reload in
                if reload {
                    self?.reloadSections()
                }
            }
        }
        return optionViewModel
    }
    
    func reloadData() {
        UseCaseWrapper(with: useCaseProvider.getFirstOnboardingPermissionsUseCase(dependencies: dependencies), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            self?.onboardingUserData?.items = result.items
            self?.reloadSections()
        })
    }
    
    func addAuthSection(keychainBiometryEnabled: Bool) -> AuthOptionOnboardingViewModel? {
        self.authViewModel = AuthOptionOnboardingViewModel(
            stringLoader: stringLoader,
            type: localAuthentication.biometryTypeAvailable,
            switchState: isBiometryAvailable && keychainBiometryEnabled,
            change: { [weak self] viewModel in
                self?.authSwitchValueChanged(inViewModel: viewModel)
        })
        return self.authViewModel
    }
    
    func addPushNotificationsSection(pushNotificationsActive: Bool, title: String?) -> PushNotificationsOptionOnboardingViewModel? {
        var getUserName: String? {
            return onboardingUserData?.userAlias.isBlank == false ? onboardingUserData?.userAlias : onboardingUserData?.userName.camelCasedString
        }
        self.pushNotificationsViewModel = PushNotificationsOptionOnboardingViewModel(
            stringLoader: stringLoader,
            userName: getUserName ?? "",
            switchState: pushNotificationsActive,
            title: title,
            change: { [weak self] viewModel in
                self?.notificationsSwitchValueChanged(inViewModel: viewModel)
        })
        return self.pushNotificationsViewModel
    }
    
    func addGeoLocationSection(locationActive: Bool, title: String?) -> LocalizationOptionOnboardingViewModel? {
        self.geoLocationViewModel = LocalizationOptionOnboardingViewModel(
            stringLoader: stringLoader,
            switchState: locationActive,
            title: title,
            change: { [weak self] viewModel in
                guard let strongSelf = self else { return }
                strongSelf.geoLocationSwitchValueChanged(inViewModel: viewModel)
        })
        return self.geoLocationViewModel
    }
    
    func checkOSSettings() -> Bool {
        if case .error = localAuthentication.biometryTypeAvailable {
            let completion = { [weak self] () in
                guard let self = self else { return }
                self.navigator.navigateToSettings()
            }
            
            var errorTitle: LocalizedStylableText = .empty
            var errorText: LocalizedStylableText = .empty
            
            switch localAuthentication.biometryTypeAvailable {
            case .faceId, .error(BiometryTypeEntity.faceId, _):
                errorTitle = localized(key: "loginTouchId_alert_title_faceIdActivate")
                errorText = localized(key: "loginTouchId_alert_faceIdActivate")
            case .touchId, .error(BiometryTypeEntity.touchId, _):
                errorTitle = localized(key: "loginTouchId_alert_title_digitalFingerprint")
                errorText = localized(key: "touchID_alert_forActivateFingerprint")
            case .error: break
            case .none: break
            }
            let acceptComponents = DialogButtonComponents(titled: localized(key: "genericAlert_buttom_settings"), does: completion)
            let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_button_cancel"), does: nil)
            Dialog.alert(title: errorTitle, body: errorText, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: view)
            
            return false
        }
        return true
    }
    
    func performFootprintRegistration(viewModel: AuthOptionOnboardingViewModel, completion: ((Bool) -> Void)? = nil) {
        var accessLoginType: String!
        switch self.localAuthentication.biometryTypeAvailable {
        case .touchId:
            accessLoginType = "touchId"
        case .faceId:
            accessLoginType = "faceId"
        default:
            accessLoginType = ""
        }
        
        UseCaseWrapper(with: useCaseProvider.registerDevice(input: RegisterDeviceInput(footPrint: view.footPrint, deviceName: view.deviceName)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            guard let self = self else { return }
            
            UseCaseWrapper(with: self.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: result.deviceMagicPhrase, touchIDLoginEnabled: result.touchIDLoginEnabled)), useCaseHandler: self.useCaseHandler, errorHandler: self.genericErrorHandler, onSuccess: { [weak self] (_) in
                self?.donateSiriIntents()
                self?.localAuthentication.enableBiometric()
                completion?(true)
                self?.reloadData()
                self?.trackEvent(eventId: OnboardingOptions.Action.biometric.rawValue, parameters: [TrackerDimension.accessLoginType.key: accessLoginType])
                }, onError: { [weak self] (_) in
                    self?.showUnabledBiometryMessage(code: nil, localizedKey: "_alert_errorActivation")
                    viewModel.switchState = false
                    self?.reloadData()
                    self?.trackEvent(eventId: OnboardingOptions.Action.biometric.rawValue, parameters: [TrackerDimension.accessLoginType.key: accessLoginType])
            })
            }, onGenericErrorType: { [weak self] (error) in
                if case let .error(errorValue) = error {
                    self?.trackEvent(
                        eventId: OnboardingOptions.Action.biometricError.rawValue,
                        parameters: [
                            TrackerDimension.descError.key: errorValue?.getErrorDesc() ?? "",
                            TrackerDimension.accessLoginType.key: accessLoginType
                        ]
                    )
                    self?.showUnabledBiometryMessage(code: errorValue?.getErrorDesc(), localizedKey: "_alert_errorActivation")
                }
                self?.reloadData()
        })
    }
    
    func showLisboaLocationPermissionsDialog(acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let info = LocationPermissionsPromptDialogData.getLocationDialogInfo(acceptAction: acceptAction,
                                                                                  cancelAction: cancelAction)
        let identifiers = LocationPermissionsPromptDialogData.getLocationDialogIdentifiers()
        showPromptDialog(info: info, identifiers: identifiers)
    }
    
    func showNativeLocationPermissions() {
        let locationManager = dependencies.locationManager
        if locationManager.isAlreadySet {
            showDisableLocationDialog()
        } else {
            trackEvent(eventId: OnboardingOptions.Action.geolocation.rawValue, parameters: [:])
            locationManager.askAuthorizationIfNeeded { [weak self] in
                locationManager.askedGlobalLocation()
                self?.reloadData()
                guard locationManager.locationServicesStatus() == .authorized else { return }
                self?.showLocationActivatedAlert()
            }
        }
    }
    
    func showUnabledBiometryMessage(code: String?, localizedKey: String) {
        var localizedKey = "touchId\(localizedKey)"
        if case .faceId = localAuthentication.biometryTypeAvailable {
            localizedKey = "\(localizedKey.replace("touchId", "faceId").replace("TouchId", "FaceId"))"
        }
        if let code = code {
            showError(code: code, keyDesc: localizedKey)
        } else {
            showError(keyDesc: localizedKey)
        }
    }
    
    func showError(code: String, keyDesc: String?) {
        var error: LocalizedStylableText = .empty
        let titleError: LocalizedStylableText = .empty
        if let keyDesc = keyDesc {
            error = stringLoader.getWsErrorString(keyDesc)
        }
        guard !error.text.isEmpty else {
            return self.view.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine)
        }
        error = LocalizedStylableText(text: error.text + " (\(code))", styles: nil)
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: nil)
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
    }
    
    func askBiometryIfNoEnabled(viewModel: AuthOptionOnboardingViewModel, completionHandler: ((Bool) -> Void)? = nil) {
        if !self.checkOSSettings() {
            completionHandler?(false)
            viewModel.switchState = false
            self.reloadData()
            return
        }
        
        let acceptCompletion: () -> Void = { [weak self] () in
            self?.performFootprintRegistration(viewModel: viewModel, completion: completionHandler)
        }
        
        let cancelCompletion = { [weak self] () in
            completionHandler?(false)
            viewModel.switchState = false
            self?.reloadData()
        }
        
        let biometryType = localAuthentication.biometryTypeAvailable
        let info = BiometryPermissionsPromptDialogData.getBiometryDialogInfo(biometryType: biometryType,
                                                                                  acceptAction: acceptCompletion,
                                                                                  cancelAction: cancelCompletion)
        let identifiers = BiometryPermissionsPromptDialogData.getBiometryDialogIdentifiers()
        showPromptDialog(info: info, identifiers: identifiers)
    }
    
    private func validateUserLoginType() -> Bool {
        return self.onboardingUserData?.loginType != .U
    }
    
    func showInvalidUserLoginTypeMessage(_ biometryType: BiometryTypeEntity) {
        switch biometryType {
        case .touchId:
            view.showUnavailableBiometryLoginAlert(localized(key: "security_alert_activateTouchId"))
        case .faceId:
            view.showUnavailableBiometryLoginAlert(localized(key: "security_alert_activateFaceId"))
        default:
            return
        }
    }
    
    func disableBiometricPermissions(_ viewModel: AuthOptionOnboardingViewModel, completion: @escaping () -> Void) {
        UseCaseWrapper(with: useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: nil, touchIDLoginEnabled: nil)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (_) in
            self?.deleteSiriIntents()
            viewModel.switchState = false
            self?.reloadData()
            completion()
            }, onError: { [weak self] (_) in
                viewModel.switchState = true
                self?.reloadData()
        })
    }
    
    func showDisableLocationDialog() {
        let completion = { [weak self] () in
            guard let self = self else { return }
            self.navigator.navigateToSettings()
        }
        let acceptComponents = DialogButtonComponents(titled: localized(key: "genericAlert_buttom_settings"),
                                                      does: completion)
        let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_button_cancel"),
                                                      does: nil)
        Dialog.alert(title: nil,
                     body: localized(key: "onboarding_alert_text_permissionActivation"),
                     withAcceptComponent: acceptComponents,
                     withCancelComponent: cancelComponents,
                     source: view)
    }
    
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers) {
        view.showPromptDialog(info: info, identifiers: identifiers, closeButtonAvailable: false)
    }
    
    func showAlert(with message: LocalizedStylableText) {
        view.showAlert(with: message, messageType: .info)
    }
    
    func showLocationActivatedAlert() {
        let okMessage = self.localized(key: "security_alert_activateLocation")
        showAlert(with: okMessage)
    }
    
    func showBiometryAlert(for state: BiometryState) {
        let alertMessage = BiometryPermissionsPromptDialogData
            .getBiometryAlertMessage(for: state, biometryType: localAuthentication.biometryTypeAvailable)
        showAlert(with: alertMessage)
    }
}

extension OnboardingOptionsPresenter: ToolTipablePresenter {
    var toolTipBackView: ToolTipBackView {
        return view
    }
}
