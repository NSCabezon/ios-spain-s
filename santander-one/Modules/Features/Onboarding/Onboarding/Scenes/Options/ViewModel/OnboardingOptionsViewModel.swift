//
//  OnboardingOptionsViewModel.swift
//  Onboarding
//
//  Created by José Hidalgo on 07/01/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Intents
import UI

final class OnboardingOptionsViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: OnboardingOptionsDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingOptionsState, Never>(.idle)
    private var userInfo: OnboardingUserInfoRepresentable?
    private lazy var getUserInfoUseCase: GetUserInfoUseCase = dependencies.resolve()
    private lazy var getOnboardingPermissionsUseCase: GetOnboardingPermissionsUseCase = {
        return dependencies.resolve()
    }()
    private lazy var getStepperValuesUseCase: GetStepperValuesUseCase = dependencies.resolve()
    
    var state: AnyPublisher<OnboardingOptionsState, Never>
    var permissions: [(OnboardingPermissionType, [Bool])]?
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: OnboardingOptionsDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        fetchUserInfo()
        trackScreen()
    }
    
    func viewWillAppear() {
        fetchOnboardingPermissions()
        fetchStepperValues()
    }
    
    func didSelectBack() {
        stepsCoordinator.back()
    }
    
    func didSelectNext() {
        stepsCoordinator.next()
    }
    
    func didAbortOnboarding(confirmed: Bool, deactivate: Bool) {
        guard confirmed else { return }
        let termination = OnboardingTermination(type: .cancelOnboarding(deactivate: deactivate), gpOption: userInfo?.globalPosition)
        onboardingCoordinator?.dataBinding.set(termination)
        onboardingCoordinator?.dismiss()
    }
}

// MARK: - Private
private extension OnboardingOptionsViewModel {
    func loadSections(permissions: [(OnboardingPermissionType, [Bool])]) {
        var sections: [OnboardingStackSection] = []
        for permission in permissions {
            let firstPermission = permission.1.first ?? false
            switch permission.0 {
            case .notifications(title: let title):
                guard let pushModel = addPushNotificationsSection(pushNotificationsActive: firstPermission, title: title) else { return }
                let section = OnboardingStackSection()
                section.add(item: pushModel)
                sections.append(section)
            case .location(title: let title):
                guard let geoLocationModel = addGeoLocationSection(locationActive: firstPermission, title: title) else { return }
                let section = OnboardingStackSection()
                section.add(item: geoLocationModel)
                sections.append(section)
            case .custom(options: let options):
                let viewModel: CustomOptionOnboardingViewModel = self.getCustomOption(options)
                let section = OnboardingStackSection()
                section.add(item: viewModel)
                sections.append(section)
            case .customWithTooltip(options: let options):
                let viewModel: CustomOptionWithTooltipOnboardingViewModel = self.getCustomOption(options)
                let section = OnboardingStackSection()
                section.add(item: viewModel)
                sections.append(section)
            }
        }
        stateSubject.send(.loadSections(sections: sections))
    }
    
    var isBiometryAvailable: Bool {
        if case .error = localAuthentication.biometryTypeAvailable {
            return false
        } else if case .none = localAuthentication.biometryTypeAvailable {
            return false
        }
        return true
    }
    
    func showAlert(with message: String) {
        let top = OnboardingOptionsStateAlertTop(messageKey: message, type: .info, duration: 4.0)
        stateSubject.send(.showAlert(.top(top)))
    }
    
    func showDisableLocationDialog() {
        let completion = { [weak self] () in
            guard let self = self else { return }
            self.stateSubject.send(.settings(()))
        }
        
        let common = OnboardingOptionsStateAlertCommon(titleKey: nil,
                                                       bodyKey: "onboarding_alert_text_permissionActivation",
                                                       acceptKey: "genericAlert_buttom_settings",
                                                       acceptAction: completion,
                                                       cancelKey: "generic_button_cancel",
                                                       cancelAction: nil)
        stateSubject.send(.showAlert(.common(common)))
    }
    
    func showLocationPermissionsDialog(acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        let info = LocationPermissionsPromptDialogData.getLocationDialogInfo(acceptAction: acceptAction,
                                                                             cancelAction: cancelAction)
        let identifiers = LocationPermissionsPromptDialogData.getLocationDialogIdentifiers()
        showPromptDialog(info: info, identifiers: identifiers)
    }
    
    func showLocationActivatedAlert() {
        showAlert(with: "security_alert_activateLocation")
    }
    
    func showNativeLocationPermissions() {
        if locationManager.isAlreadySet {
            showDisableLocationDialog()
        } else {
            let eventId = OnboardingOptions.Action.geolocation.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
            locationManager.askAuthorizationIfNeeded { [weak self] in
                self?.locationManager.setGlobalLocationAsked()
                self?.fetchOnboardingPermissions()
                guard self?.locationManager.locationServicesStatus() == .authorized else { return }
                self?.showLocationActivatedAlert()
            }
        }
    }
    
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers) {
        let prompt = OnboardingOptionsStateAlertPrompt(info: info, identifiers: identifiers, closeButtonAvailable: false)
        stateSubject.send(.showAlert(.prompt(prompt)))
    }
    
    func showBiometryAlert(_ state: BiometryState, biometryTypeAvailable: BiometryTypeEntity) {
        let alertMessage = BiometryPermissionsPromptDialogData
            .getBiometryAlertMessage(for: state, biometryType: biometryTypeAvailable)
        let stateAlert = OnboardingOptionsStateAlertTop(messageKey: alertMessage.text,
                                                        type: .info,
                                                        duration: 2.0)
        stateSubject.send(.showAlert(.top(stateAlert)))
    }
    
    func fetchUserInfo() {
        getUserInfoUseCase
            .fetch()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] value in
                self?.userInfo = value
            }).store(in: &anySubscriptions)
    }
}

// MARK: - Dependencies
private extension OnboardingOptionsViewModel {
    var localAppConfig: LocalAppConfig {
        return dependencies.external.resolve()
    }
    
    var locationManager: LocationPermissionsManagerProtocol {
        return dependencies.external.resolve()
    }
    
    var onboardingCoordinator: OnboardingCoordinator? {
        return dependencies.resolve()
    }
    
    var stepsCoordinator: StepsCoordinator<OnboardingStep> {
        return dependencies.resolve()
    }
    
    var stringLoader: StringLoader {
        return dependencies.external.resolve()
    }
    
    var localAuthentication: LocalAuthenticationPermissionsManagerProtocol {
        return dependencies.external.resolve()
    }
    
    var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol {
        return dependencies.external.resolve()
    }
    
    var configuration: OnboardingConfiguration {
        return dependencies.external.resolve()
    }
}

// MARK: - Option Sections
extension OnboardingOptionsViewModel {
    func addPushNotificationsSection(pushNotificationsActive: Bool, title: String?) -> PushNotificationsOptionOnboardingViewModel? {
        let pushNotificationsViewModel = PushNotificationsOptionOnboardingViewModel(
            stringLoader: stringLoader,
            userName: "",
            switchState: pushNotificationsActive,
            title: title,
            change: { [weak self] viewModel in
                guard let self = self else { return }
                self.notificationsSwitchValueChanged(inViewModel: viewModel)
            })
        return pushNotificationsViewModel
    }
    
    func addGeoLocationSection(locationActive: Bool, title: String?) -> LocalizationOptionOnboardingViewModel? {
        let geoLocationViewModel = LocalizationOptionOnboardingViewModel(
            stringLoader: stringLoader,
            switchState: locationActive,
            title: title,
            change: { [weak self] viewModel in
                guard let self = self else { return }
                self.geoLocationSwitchValueChanged(inViewModel: viewModel)
            })
        return geoLocationViewModel
    }
    
    func getCustomOption(_ options: CustomOptionOnboarding) -> CustomOptionOnboardingViewModel {
        let optionViewModel = CustomOptionOnboardingViewModel(stringLoader: stringLoader,
                                                              titleKey: options.titleKey,
                                                              descriptionKey: options.textKey,
                                                              imageName: options.imageName,
                                                              switchText: options.switchText,
                                                              switchState: options.isEnabled()) { _ in
            options.action { [weak self] reload in
                if reload {
                    self?.fetchOnboardingPermissions()
                }
            }
        }
        return optionViewModel
    }
    
    func getCustomOption(_ options: CustomOptionWithTooltipOnboarding) -> CustomOptionWithTooltipOnboardingViewModel {
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
        let stringLoader: StringLoader = dependencies.external.resolve()
        let optionViewModel = CustomOptionWithTooltipOnboardingViewModel(
            stringLoader: stringLoader,
            titleKey: options.titleKey,
            descriptionKey: options.textKey,
            imageName: options.imageName,
            cellViewModel: cellViewModels) { cell in
                cell.action { [weak self] reload in
                    if reload {
                        self?.fetchOnboardingPermissions()
                    }
                }
            }
        return optionViewModel
    }
}

// MARK: - Switch Changed Events
extension OnboardingOptionsViewModel {
    func notificationsSwitchValueChanged(inViewModel viewModel: PushNotificationsOptionOnboardingViewModel) {
        let permissionsManager = notificationPermissionsManager
        permissionsManager.isAlreadySet { [weak self] isAlreadySet in
            guard let self = self else { return }
            if isAlreadySet {
                DispatchQueue.main.async {
                    let completion = { [weak self] () in
                        guard let self = self else { return }
                        self.stateSubject.send(.settings(()))
                    }
                    let common = OnboardingOptionsStateAlertCommon(titleKey: nil,
                                                                   bodyKey: "onboarding_alert_text_permissionActivation",
                                                                   acceptKey: "genericAlert_buttom_settings",
                                                                   acceptAction: completion,
                                                                   cancelKey: "generic_button_cancel",
                                                                   cancelAction: nil)
                    self.stateSubject.send(.showAlert(.common(common)))
                }
            } else {
                let eventId = OnboardingOptions.Action.notifications.rawValue
                self.trackerManager.trackEvent(screenId: self.trackerPage.page, eventId: eventId, extraParameters: [:])
                permissionsManager.requestAccess { [weak self] _ in
                    self?.stateSubject.send(.hideLoading(()))
                    self?.fetchOnboardingPermissions()
                }
            }
        }
    }
    
    func geoLocationSwitchValueChanged(inViewModel viewModel: LocalizationOptionOnboardingViewModel) {
        stateSubject.send(.hideLoading(()))
        guard viewModel.switchState else {
            showNativeLocationPermissions()
            return
        }
        if self.localAppConfig.isEnabledOnboardingLocationDialog {
            showLocationPermissionsDialog(acceptAction: { [weak self] in
                self?.showNativeLocationPermissions()
            }, cancelAction: { [weak self] in
                viewModel.switchState = false
                self?.fetchOnboardingPermissions()
            })
        } else {
            self.showNativeLocationPermissions()
        }
    }

    func handleStepperValues(_ stepperValues: OnboardingStepperValuesRepresentable) {
        guard let currentPosition = stepperValues.currentPosition else {
            stateSubject.send(.navigationItems(OnboardingOptionsStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                        currentPosition: nil,
                                                                                        total: stepperValues.totalSteps)))
            return
        }
        stateSubject.send(.navigationItems(OnboardingOptionsStateNavigationItems(allowAbort: configuration.allowAbort,
                                                                                    currentPosition: currentPosition,
                                                                                    total: stepperValues.totalSteps)))
    }

}

// MARK: - Subscriptions
private extension OnboardingOptionsViewModel {
    func fetchOnboardingPermissions() {
        anySubscriptions.removeAll()
        getOnboardingPermissionsUseCase.fetch()
            .receive(on: Schedulers.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] permissions in
                self?.permissions = permissions
                self?.loadSections(permissions: permissions)
            })
            .store(in: &anySubscriptions)
    }
    
    func fetchStepperValues() {
        getStepperValuesUseCase.fetch()
            .sink { [unowned self] stepperValues in
                self.handleStepperValues(stepperValues)
            }
            .store(in: &anySubscriptions)
     }
}

// MARK: - Analytics
extension OnboardingOptionsViewModel: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: OnboardingOptions {
        OnboardingOptions()
    }
}

// MARK: - ToolTip
extension OnboardingOptionsViewModel: ToolTipablePresenter {
    var toolTipBackView: ToolTipBackView {
        let viewController: OnboardingOptionsViewController = dependencies.resolve()
        return viewController
    }
}
