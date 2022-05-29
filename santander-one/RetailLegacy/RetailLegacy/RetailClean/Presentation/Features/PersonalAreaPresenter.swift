import Foundation
import CoreFoundationLib

private protocol SettingSectionContext {
    var userIsOperative: Bool { get }
    var personalAreaOffers: [PullOfferLocation: Offer] { get }
    var personalAreaCMCViewModelDelegate: PersonalAreaCMCCellViewModelDelegate { get }
    var currentLanguage: String { get }
}

class PersonalAreaPresenter: PrivatePresenter<PersonalAreaViewController, PersonalAreaNavigatorProtocol & PullOffersActionsNavigatorProtocol, PersonalAreaPresenterProtocol> {
    
    // MARK: - TrackerManager
    
    //TODO: (EMMA_REPLACE) replaces emma event ID
    let personalAreaEventID = "e4744e9e6b9a866a7d042f18260c1603"
    
    override var screenId: String? {
        return TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page
    }
    
    override var emmaScreenToken: String? {
        return TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).emmaToken
    }
    
    fileprivate var userIsOperative: Bool = false
    fileprivate var isPendingPays: Bool = false
    fileprivate var personalAreaOffers: [PullOfferLocation: Offer] = [:]
    
    private var localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    private var operativeUserPhone: String?
    private var touchIDViewModel: PersonalAreaSwitchCellViewModel?
    private var widgetViewModel: PersonalAreaSwitchCellViewModel?
    private var alertIsPresent = false
    private var personalAreaConfig: PersonalAreaConfig?
    private let compilation: CompilationProtocol
    /// Biometry can be used because it has no errors asociated.
    private var isBiometryAvailable: Bool {
        if case .error = localAuthentication.biometryTypeAvailable {
            return false
        } else if case .none = localAuthentication.biometryTypeAvailable {
            return false
        }
        return true
    }
    
    /// The device can use biometry.
    private var deviceHasBiometry: Bool {
        if case .none = localAuthentication.biometryTypeAvailable {
            return false
        } else if case .error(.none, _) = localAuthentication.biometryTypeAvailable {
            return false
        }
        return true
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().personalArea
    }
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    override func initOperations() {
        super.initOperations()
        loadPersonalAreaConfig { [weak self] in
            self?.getCMCOperativity { [weak self] in
                self?.getCandidateOffers { [weak self] candidates in
                    self?.personalAreaOffers = candidates
                    guard let self = self else { return }
                    self.notificationPermissionsManager?.getAuthStatus { status in
                        Scenario(useCase: self.useCaseProvider.getTouchIdLoginData())
                            .execute(on: self.dependencies.useCaseProvider.dependenciesResolver.resolve())
                            .onSuccess({ result in
                                guard self.isBiometryAvailable == true &&
                                        result.touchIdData.touchIDLoginEnabled
                                else {
                                    self.setWidgetAccessEnabled(false)
                                    self.makeSections(keychainBiometryEnabled: result.touchIdData.touchIDLoginEnabled,
                                                      isPushNotificationsEnabled: status == .authorized)
                                    return
                                }
                                self.getWidgetAccess(loginEnabled: result.touchIdData.touchIDLoginEnabled,
                                                     pushNotificationsEnabled: status == .authorized)
                            })
                            .onError { (_) in
                                self.makeSections(keychainBiometryEnabled: false,
                                                  isPushNotificationsEnabled: status == .authorized)
                            }
                    }
                }
            }
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_personalArea")
    }
    
    func reloadWhenComingBack() {
        view.resetTableView()
        initOperations()
    }
    
    init(localAuthentication: LocalAuthenticationPermissionsManagerProtocol, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PersonalAreaNavigatorProtocol & PullOffersActionsNavigatorProtocol) {
        self.localAuthentication = localAuthentication
        self.compilation =
            dependencies.useCaseProvider.dependenciesResolver.resolve(for: CompilationProtocol.self)
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    private func getCMCOperativity(completion: @escaping () -> Void) {
        let useCase = useCaseProvider.getCMCAndSupportPhoneUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.userIsOperative = !response.isConsultiveUser
            self?.operativeUserPhone = response.phone
            completion()
        })
    }
    
    private func loadPersonalAreaConfig(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: useCaseProvider.getLoadPersonalAreaConfigUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.personalAreaConfig = response.config
                completion()
            }
        )
    }
    
    private func select(option: SettingOption) {
        switch option {
        case .customizeApp:
            navigator.navigateToCustomizeApp()
        case .activateSignature:
            goToActivateSignature()
        case .changeSignature:
            let useCase = useCaseProvider.setupSignatureUseCase(input: SetupSignatureUseCaseInput(settingOption: .changeSignature))
            
            UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
                guard let strongSelf = self else { return }
                
                let operative = ChangeSignOperative(dependencies: strongSelf.dependencies)
                strongSelf.navigator.goToOperative(operative, withParameters: [result.operativeConfig], dependencies: strongSelf.dependencies)
            })
        case .language:
            break
        case .visualOptions:
            navigator.navigateToVisualOptions()
        case .notifications:
            didSelectBanner(location: .AREA_PERSONAL_ALERTAS_SSC)
        case .contactData:
            didSelectBanner(location: .DATOS_CONTACTO)
        case .income:
            didSelectBanner(location: .RENTA_ANUAL)
        case .management:
            didSelectBanner(location: .GDPR)
        case .favoriteRecipients:
            didSelectBanner(location: .GESTION_FAVORITOS)
        case .pullOffer:
            didSelectBanner(location: .RECOBRO)
        case .frequentOperative:
            navigator.navigateToFrequentOperatives()
        case .otpPush:
            goToOTPPushOption()
        case .permissions:
            navigator.navigateToPermissions()
        default:
            break
        }
    }
    
    private func goToOTPPushOption() {
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
        UseCaseWrapper(with: useCaseProvider.getGetOTPPushDeviceUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.hideLoading(completion: { [weak self] in
                self?.navigator.goToOtpPushInfo(device: response.device)
            })
        }, onError: { [weak self] error in
            guard let error = error else { return }
            self?.hideLoading(completion: { [weak self] in
                guard let self = self else { return }
                switch error.codeError {
                case .technicalError:
                    self.showError(keyDesc: error.getErrorDesc())
                case .unregisteredDevice:
                    self.launchOtpPushOperative(device: nil, withDelegate: self)
                case .differentsDevices:
                    self.showError(keyDesc: error.getErrorDesc())
                case .serviceFault:
                    self.showError(keyDesc: error.getErrorDesc())
                }
            })
        })
    }
    
    private func makeSections(keychainBiometryEnabled: Bool, isPushNotificationsEnabled: Bool, isWidgetEnabled: Bool = false) {
        UseCaseWrapper(with: useCaseProvider.getPersonalAreaOptionsUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            self?.view.sections = self?.makeSections(from: response, keychainBiometryEnabled: keychainBiometryEnabled, isWidgetEnabled: isWidgetEnabled, isPushNotificationsEnabled: isPushNotificationsEnabled) ?? []
        })
    }
    
    private func makeSections(from okOutput: GetPersonalAreaOptionsUseCaseOkOutput, keychainBiometryEnabled: Bool, isWidgetEnabled: Bool, isPushNotificationsEnabled: Bool) -> [TableModelViewSection] {
        
        return okOutput.sections.compactMap { section in
            let sectionViewModel = TableModelViewSection()
            let title = SettingsTitleHeaderViewModel(title: dependencies.stringLoader.getString(section.0.keyValue))
            sectionViewModel.setHeader(modelViewHeader: title)
            
            section.1.forEach { option in
                if [.touchID, .widgetAccess].contains(option) {
                    guard deviceHasBiometry else { return }
                    option.addViewModel(section: sectionViewModel, with: dependencies, context: self, biometryType: localAuthentication.biometryTypeAvailable, activeBiometry: isBiometryAvailable && keychainBiometryEnabled, isPushNotificationsEnabled: isPushNotificationsEnabled, personalAreaConfig: personalAreaConfig, selector: nil)
                    if case .touchID = option {
                        self.touchIDViewModel = sectionViewModel.items.last as? PersonalAreaSwitchCellViewModel
                    } else {
                        self.widgetViewModel = sectionViewModel.items.last as? PersonalAreaSwitchCellViewModel
                        self.widgetViewModel?.value = isWidgetEnabled
                    }
                } else {
                    option.addViewModel(section: sectionViewModel, with: dependencies, context: self, activeBiometry: nil, isPushNotificationsEnabled: isPushNotificationsEnabled, personalAreaConfig: personalAreaConfig) { [weak self] in
                        self?.select(option: option)
                    }
                }
            }
            let lastIndex = (sectionViewModel.getItems()?.count ?? 0) - 1
            sectionViewModel.getItems()?.map { $0 as? GroupableCell }.enumerated().forEach { index, item in
                item?.isFirst = index == 0
                item?.isLast = index == lastIndex
                item?.isSeparatorVisible = item?.isLast == false
            }
            guard sectionViewModel.getItems()?.isEmpty == false else {
                return nil
            }
            return sectionViewModel
        }
    }
    
    private func checkOSSettings(andDisplayMessageKey key: String) -> Bool {
        if case .error = localAuthentication.biometryTypeAvailable {
            
            let error: LocalizedStylableText = localized(key: key)
            let completion = {() in
                //IR A AJUSTES
                self.navigator.navigateToSettings()
            }
            
            let acceptComponents = DialogButtonComponents(titled: localized(key: "genericAlert_buttom_settings_android"), does: completion)
            let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_button_cancel"), does: nil)
            Dialog.alert(title: .empty, body: error, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: view)
            
            return false
        }
        
        return true
    }
    
    private func performFootprintRegistration(viewModel: PersonalAreaSwitchCellViewModel, shouldDisplayMessage: Bool, completion: ((Bool) -> Void)? = nil) {
        
        let type = LoadingViewType.onScreen(controller: view, completion: nil)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
        
        UseCaseWrapper(with: useCaseProvider.registerDevice(input: RegisterDeviceInput(footPrint: view.footPrint, deviceName: view.deviceName)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            
            UseCaseWrapper(with: strongSelf.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: result.deviceMagicPhrase, touchIDLoginEnabled: result.touchIDLoginEnabled)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (_) in
                
                self?.donateSiriIntents()
                self?.localAuthentication.enableBiometric()
                
                guard let strongSelfUW = self else { return }
                strongSelfUW.hideLoading(completion: {() in
                    if shouldDisplayMessage {
                        strongSelfUW.showUnabledBiometryMessage(code: nil, localizedKey: "_alert_activeSuccess")
                    }
                    completion?(true)
                }, tag: 0)
            }, onError: { [weak self] (_) in
                guard let strongSelfUW = self else { return }
                strongSelfUW.hideLoading(completion: {() in
                    strongSelfUW.showUnabledBiometryMessage(code: nil, localizedKey: "_alert_errorActivation")
                    viewModel.value = false
                    strongSelfUW.view.reloadSections()
                }, tag: 0)
            })
            
        }, onGenericErrorType: { [weak self] (error) in
            if case let .error(errorValue) = error {
                self?.hideLoading(completion: { [weak self] in
                    self?.showUnabledBiometryMessage(code: errorValue?.getErrorDesc(), localizedKey: "_alert_errorActivation")
                    self?.touchIDViewModel?.value = false
                    self?.widgetViewModel?.value = false
                    self?.view.reloadSections()
                }, tag: 0)
            } else {
                self?.touchIDViewModel?.value = false
                self?.widgetViewModel?.value = false
                self?.view.reloadSections()
            }
        })
    }
    
    private func showUnabledBiometryMessage(code: String?, localizedKey: String) {
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
    
    private func didSelectBanner(location: PullOfferLocation) {
        guard let offer = personalAreaOffers[location], let offerAction = offer.action else { return }
        executeOffer(action: offerAction, offerId: offer.id, location: location)
    }
    
    func showError(code: String, keyDesc: String?) {
        var error: LocalizedStylableText = .empty
        let titleError: LocalizedStylableText = .empty
        if let keyDesc = keyDesc {
            error = stringLoader.getWsErrorString(keyDesc)
        }
        guard !error.text.isEmpty else { return self.view.showGenericErrorDialog(withDependenciesResolver: self.dependencies.navigatorProvider.dependenciesEngine) }
        error = LocalizedStylableText(text: error.text + " (\(code))", styles: nil)
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: nil)
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: nil, source: view)
    }
}

extension PersonalAreaPresenter: SiriIntentsOperator {}

enum SettingSection {
    case setup
    case yourData
    case security
    case fineTune
    case extra
    
    var keyValue: String {
        switch self {
        case .setup:
            return "personalArea_label_appSetting"
        case .yourData:
            return "personalArea_label_data"
        case .security:
            return "personalArea_label_security"
        case .fineTune:
            return "personalArea_label_setting"
        case .extra:
            return ""
        }
    }
    
}

enum SettingOption {
    case customizeApp
    case language
    case appInfo
    case contactData
    case income
    case management
    case touchID
    case widgetAccess
    case changeSignature
    case activateSignature
    case user
    case notifications
    case favoriteRecipients
    case pullOffer
    case visualOptions
    case frequentOperative
    case otpPush
    case permissions
    
    private var keyValue: String {
        switch self {
        case .customizeApp:
            return "personalArea_label_appCustomize"
        case .language:
            return "personalArea_label_language"
        case .appInfo:
            return "personalArea_label_appInformation"
        case .income:
            return "personalArea_label_income"
        case .management:
            return "personalArea_label_allow"
        case .touchID:
            return "personalArea_label_touchId"
        case .changeSignature:
            return "personalArea_label_signingChange"
        case .activateSignature:
            return "personalArea_label_signingActivate"
        case .user:
            return "personalArea_label_user"
        case .notifications:
            return "personalArea_label_alert"
        case .pullOffer:
            return "personalArea_label_pendingPays"
        case .visualOptions:
            return "appSetting_label_displayOptions"
        case .contactData:
            return "personalArea_label_contactData"
        case .favoriteRecipients:
            return "personalArea_label_favoriteRecipients"
        case .widgetAccess:
            return "personalArea_label_widget"
        case .frequentOperative:
            return "personalArea_label_frequentOperative"
        case .otpPush:
            return "personalArea_label_secureDevice"
        case .permissions:
            return "personalArea_label_permissionManagement"
        }
    }
    
    fileprivate func addViewModel(section: TableModelViewSection, with dependencies: PresentationComponent, context: SettingSectionContext, biometryType: BiometryTypeEntity? = nil, activeBiometry: Bool?, isPushNotificationsEnabled: Bool, personalAreaConfig: PersonalAreaConfig?, selector: (() -> Void)? ) {
        let title = dependencies.stringLoader.getString(self.keyValue)
        switch self {
        case .customizeApp, .appInfo, .changeSignature, .activateSignature, .visualOptions, .frequentOperative, .permissions:
            let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
            option.didSelect = selector
            section.add(item: option)
        case .notifications:
            if context.personalAreaOffers[.AREA_PERSONAL_ALERTAS_SSC] != nil {
                let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .contactData:
            if context.personalAreaOffers[.DATOS_CONTACTO] != nil {
                let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .income:
            if context.personalAreaOffers[.RENTA_ANUAL] != nil {
                let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .management:
            if context.personalAreaOffers[.GDPR] != nil {
                let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .favoriteRecipients:
            if context.personalAreaOffers[.GESTION_FAVORITOS] != nil {
                let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .language:
            let option = PersonalAreaLinkCellViewModel(title: title, value: context.currentLanguage, dependencies: dependencies)
            option.didSelect = selector
            section.add(item: option)
        case .touchID:
            let title: LocalizedStylableText?
            switch biometryType {
            case .faceId?, .error(BiometryTypeEntity.faceId, _)?:
                title = dependencies.stringLoader.getString("personalArea_label_faceId")
            case .touchId?, .error(BiometryTypeEntity.touchId, _)?:
                title = dependencies.stringLoader.getString("personalArea_label_touchId")
            case .error?:
                title = dependencies.stringLoader.getString("PERSONA 4 LA ANIMACION")
            case .none?, nil:
                title = .empty
            }
            
            let option = PersonalAreaSwitchCellViewModel(title: title, value: activeBiometry ?? false, dependencies: dependencies)
            option.didSelect = nil
            option.didChangeSwitch = { viewModel in
                let context = context as? PersonalAreaSwitchCellViewModelDelegate
                if case .touchId? = biometryType {
                    context?.trackEventSwitchTouchIdChange(activate: viewModel.value)
                }
                context?.switchValueChanged(inViewModel: viewModel)
            }
            section.add(item: option)
        case .widgetAccess:
            let option = PersonalAreaSwitchCellViewModel(title: title, value: false, dependencies: dependencies)
            option.didSelect = nil
            option.didChangeSwitch = { viewModel in
                let context = context as? PersonalAreaSwitchCellViewModelDelegate
                context?.trackEventSwitchWidgetChange(activate: viewModel.value)
                context?.switchWidgetDidChange(inViewModel: viewModel)
            }
            section.add(item: option)
        case .user:
            let stringLoader = dependencies.stringLoader
            let textKey = context.userIsOperative ? "personalArea_label_operative" : "personalArea_label_consultative"
            let text = stringLoader.getString(textKey)
            let option = PersonalAreaCMCCellViewModel(title: title, value: (text, context.userIsOperative), dependencies: dependencies)
            option.delegate = context.personalAreaCMCViewModelDelegate
            option.didSelect = selector
            section.add(item: option)
        case .pullOffer:
            if context.personalAreaOffers[.RECOBRO] != nil {
                let option = PersonalAreaIconedCellViewModel(icon: PersonalAreaIcon.pendingPayments, title: title, dependencies: dependencies)
                option.didSelect = selector
                section.add(item: option)
            }
        case .otpPush:
            guard let personalAreaConfig = personalAreaConfig, personalAreaConfig.isOTPPushEnabled, isPushNotificationsEnabled else { return }
            let option = PersonalAreaOneLineViewModel(text: title, dependencies: dependencies)
            option.didSelect = selector
            section.add(item: option)
        }
    }
}

extension PersonalAreaPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension PersonalAreaPresenter: PersonalAreaSwitchCellViewModelDelegate {
    func trackEventSwitchTouchIdChange(activate: Bool) {
        if activate {
            track(event: TrackerPagePrivate.PersonalArea.Action.touchOn.rawValue, screen: screenId ?? "", parameters: [:])
        } else {
            track(event: TrackerPagePrivate.PersonalArea.Action.touchOff.rawValue, screen: screenId ?? "", parameters: [:])
        }
    }
    
    func trackEventSwitchWidgetChange(activate: Bool) {
        if activate {
            track(event: TrackerPagePrivate.PersonalArea.Action.widgetOn.rawValue, screen: screenId ?? "", parameters: [:])
        } else {
            track(event: TrackerPagePrivate.PersonalArea.Action.widgetOff.rawValue, screen: screenId ?? "", parameters: [:])
        }
    }
    
    func switchWidgetDidChange(inViewModel viewModel: PersonalAreaSwitchCellViewModel) {
        if viewModel.value == true {
            let completion: ((Bool) -> Void) = { [weak self] success in
                self?.touchIDViewModel?.value = success
                self?.setWidgetAccessEnabled(success, shouldDisplayMessage: success)
            }
            assert(touchIDViewModel != nil)
            if let touchIDViewModel = touchIDViewModel, touchIDViewModel.value == false {
                askBiometryIfNoEnabled(withTitleKey: "personalArea_alert_text_widget", viewModel: touchIDViewModel, shouldDisplayBiometryMessage: false, completionHandler: completion)
            } else {
                completion(true)
            }
        } else {
            setWidgetAccessEnabled(false, shouldDisplayMessage: true)
        }
    }
    
    fileprivate func displayWidgetMessage(withStatus isEnabled: Bool) {
        if isEnabled {
            showError(keyDesc: "widget_label_activateWidget")
        } else {
            showError(keyDesc: "widget_label_disableWidget")
        }
    }
    
    /// Calls the set widget state use case, updates the model value and reloads the section.
    private func setWidgetAccessEnabled(_ isEnabled: Bool, shouldDisplayMessage: Bool = false, completion: ((Bool) -> Void)? = nil) {
        let input = SetWidgetAccessInput(isWidgetEnabled: isEnabled)
        UseCaseWrapper(with: useCaseProvider.setWidgetAccess(input: input), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, queuePriority: .normal, onSuccess: { [weak self] _ in
            self?.widgetViewModel?.value = isEnabled
            completion?(true)
            if shouldDisplayMessage {
                self?.displayWidgetMessage(withStatus: isEnabled)
            }
            self?.view.reloadSections()
        }, onError: { _ in
            completion?(false)
        })
    }
    
    private func askBiometryIfNoEnabled(withTitleKey key: String, viewModel: PersonalAreaSwitchCellViewModel, shouldDisplayBiometryMessage: Bool, completionHandler: ((Bool) -> Void)? = nil) {
        if !self.checkOSSettings(andDisplayMessageKey: key) {
            completionHandler?(false)
            viewModel.value = false
            self.view.reloadSections()
            return
        }
        
        var localizedKey = "touchId_alert_rememberUser"
        if case .faceId = localAuthentication.biometryTypeAvailable {
            localizedKey = "faceId_alert_rememberUser"
        }
        
        let error: LocalizedStylableText = localized(key: localizedKey)
        let completion: () -> Void = { [weak self] () in
            self?.performFootprintRegistration(viewModel: viewModel, shouldDisplayMessage: shouldDisplayBiometryMessage, completion: completionHandler)
        }
        
        let cancelCompletion = { [weak self] () in
            completionHandler?(false)
            viewModel.value = false
            self?.view.reloadSections()
        }
        
        let acceptComponents = DialogButtonComponents(titled: localized(key: "generic_button_accept"), does: completion)
        let cancelComponents = DialogButtonComponents(titled: localized(key: "generic_button_cancel"), does: cancelCompletion)
        Dialog.alert(title: .empty, body: error, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: view)
    }
    
    func switchValueChanged(inViewModel viewModel: PersonalAreaSwitchCellViewModel) {
        if viewModel.value {
            askBiometryIfNoEnabled(withTitleKey: "noenrollment_alert_forActivateEnrollment", viewModel: viewModel, shouldDisplayBiometryMessage: true)
        } else if !isBiometryAvailable {
            /// You can get in this situation by holding your finger down while switching when you cannot activate widget.
            viewModel.value = false
        } else {
            alertIsPresent = true
            setWidgetAccessEnabled(false, shouldDisplayMessage: false) { [weak self] success in
                guard let strongSelf = self, success == true else { return }
                UseCaseWrapper(with: strongSelf.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: nil, touchIDLoginEnabled: nil)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (_) in
                    self?.deleteSiriIntents()
                    guard let strongSelf = self else { return }
                    viewModel.value = false
                    strongSelf.view.reloadSections()
                    strongSelf.alertIsPresent = false
                    strongSelf.showUnabledBiometryMessage(code: nil, localizedKey: "_alert_desactiveTouchId")
                    
                }, onError: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    viewModel.value = true
                    strongSelf.alertIsPresent = false
                    strongSelf.view.reloadSections()
                    strongSelf.showError(keyDesc: nil)
                })
            }
        }
    }
    
    private func getWidgetAccess(loginEnabled: Bool, pushNotificationsEnabled: Bool) {
        Scenario(useCase: self.useCaseProvider.getWidgetAccess())
            .execute(on: self.dependencies.useCaseProvider.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.makeSections(keychainBiometryEnabled: loginEnabled,
                                   isPushNotificationsEnabled: pushNotificationsEnabled,
                                   isWidgetEnabled: response.isWidgetEnabled)
            }
            .onError { [weak self] _ in
                self?.makeSections(keychainBiometryEnabled: loginEnabled,
                                   isPushNotificationsEnabled: pushNotificationsEnabled)
            }
    }
}

extension PersonalAreaPresenter: PersonalAreaPresenterProtocol {
    func selected(indexPath: IndexPath) {
        let actionableItem = view.sections[indexPath.section].items[indexPath.row] as? Executable
        actionableItem?.execute()
    }
}

extension PersonalAreaPresenter: SettingSectionContext {
    var personalAreaCMCViewModelDelegate: PersonalAreaCMCCellViewModelDelegate {
        return self
    }
    
    var currentLanguage: String {
        let currentLanguage = stringLoader.getCurrentLanguage()
        return currentLanguage.languageType.languageName.capitalizedBySentence()
    }
}

extension PersonalAreaPresenter: PersonalAreaCMCCellViewModelDelegate {
    var toolTipBackView: ToolTipBackView {
        return view
    }
    
    var tooltipMessage: LocalizedStylableText {
        if let phone = operativeUserPhone {
            return stringLoader.getString("personalArea_tooltip_phone", [StringPlaceholder(.phone, phone)])
        } else {
            return stringLoader.getString("personalArea_tooltip_signature")
        }
    }
}

extension PersonalAreaPresenter: Presenter {}

extension PersonalAreaPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return !alertIsPresent
    }
}

extension PersonalAreaPresenter: LocationsResolver {}

extension PersonalAreaPresenter: ActivateSignatureLauncher {
    var activateSignatureLauncherNavigator: OperativesNavigatorProtocol {
        return navigator
    }
    
    func showError(keyDesc: String?) {
        showError(keyTitle: nil, keyDesc: keyDesc, phone: nil, completion: nil)
    }
}

extension PersonalAreaPresenter: EnableOtpPushOperativeLauncher {}

extension PersonalAreaPresenter: OperativeLauncherDelegate {
    
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
}

extension PersonalAreaPresenter: OperativeLauncherPresentationDelegate {
    
    func startOperativeLoading(completion: @escaping () -> Void) {
        let type = LoadingViewType.onScreen(controller: view, completion: completion)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        hideLoading(completion: completion)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: view)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
    
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return genericErrorHandler
    }
}
