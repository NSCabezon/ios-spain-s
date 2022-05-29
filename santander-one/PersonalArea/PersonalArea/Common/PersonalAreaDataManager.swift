//
//  PersonalAreaDataManager.swift
//  PersonalArea
//
//  Created by alvola on 26/11/2019.
//

import CoreFoundationLib

protocol PersonalAreaDataManagerProtocol: AnyObject {
    func getUserPreference() -> UserPrefWrapper
    func getAvatarImage(_ success: @escaping (GetPersistedUserAvatarUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func setUserAvatarImage(_ image: Data, onSuccess: ((Void) -> Void)?)
    func getCurrentLanguage(_ success: @escaping (GetLanguagesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func updateCurrentLanguage(language: LanguageType, _ success: @escaping (UpdateLanguageUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func updateUserPref(_ userPref: UserPrefWrapper)
    func updateUserPreferencesValues(userPrefEntity: UserPrefEntity, onSuccess: ((Void) -> Void)?, onError: ((UseCaseError<StringErrorOutput>) -> Void)?)
    func getOTPPushDevice(_ success: @escaping (OTPPushDeviceEntity?) -> Void, failure: @escaping (String) -> Void)
    func getUserPrefs(_ success: @escaping (GetPersonalAreaDataUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void)
    func getAvailablePullOffers(_ locations: [PullOfferLocation], onSuccess: ((GetPullOffersUseCaseOutput?) -> Void)?)
    func getUserBasicInfo(onSuccess success: @escaping (GetPersonalBasicInfoUseCaseOkOutput) -> Void, failure: ((String) -> Void)?)
    func loadPersonalAreaPreferences(_ completion: @escaping () -> Void)
    func getPermissions(_ success: @escaping (GetPermissionsUseCaseOkOutput) -> Void)
    func getOtherOperativesWrapper(locations: [PullOfferLocation], _ success: @escaping (GetOtherOperativesWrapperUseCaseOkOutput) -> Void)
}

public final class PersonalAreaDataManager: PersonalAreaDataManagerProtocol {
    private var dependenciesEngine: DependenciesDefault
    private let userPreferencesDependencies: UserPreferencesDependenciesResolver
    private var userPref = UserPrefWrapper()
    
    init(dependenciesEngine: DependenciesResolver,
         userPreferencesDependencies: UserPreferencesDependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesEngine)
        self.userPreferencesDependencies = userPreferencesDependencies
        self.setupDependencies()
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: UpdatePersonalAreaDataUseCase.self) { _ in
            return UpdatePersonalAreaDataUseCase()
        }
        self.dependenciesEngine.register(for: UpdateLanguageUseCase.self) { dependenciesResolver in
            return UpdateLanguageUseCase(dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SetPersistedUserAvatarUseCase.self) { _ in
            return SetPersistedUserAvatarUseCase()
        }
        self.dependenciesEngine.register(for: GetLanguagesUseCase.self) { dependenciesResolver in
            return GetLanguagesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetOTPPushDeviceUseCase.self) { dependenciesResolver in
            return GetOTPPushDeviceUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPersonalBasicInfoUseCaseProtocol.self) { dependenciesResolver in
            return GetPersonalBasicInfoUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPersonalAreaDataUseCase.self) { dependenciesResolver in
            return GetPersonalAreaDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetPermissionsUseCase.self) { resolver in
            return GetPermissionsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetPersistedUserAvatarUseCase.self) { _ in
            return GetPersistedUserAvatarUseCase()
        }
        self.dependenciesEngine.register(for: GetPullOffersUseCase.self) { dependenciesResolver in
            return GetPullOffersUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetOtherOperativesWrapperUseCase.self) { resolver in
            return GetOtherOperativesWrapperUseCase(dependenciesResolver: resolver)
        }
    }
    
    func getUserPreference() -> UserPrefWrapper {
        if let modifier = dependenciesEngine.resolve(forOptionalType: PersonalAreaMainModuleModifier.self) {
            userPref.username = modifier.getName()
        }
        return userPref
    }
    
    private var locationPermissionManager: LocationPermissionsManagerProtocol? {
        let configuration: PersonalAreaConfiguration = dependenciesEngine.resolve(for: PersonalAreaConfiguration.self)
        return configuration.locationPermissionsManager
    }
    
    private var contactsPermissionManager: ContactPermissionsManagerProtocol? {
        let configuration: PersonalAreaConfiguration = dependenciesEngine.resolve(for: PersonalAreaConfiguration.self)
        return configuration.contactsPermissionsManager
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesEngine.resolve(for: LocalAppConfig.self)
    }
    
    func getAvatarImage(_ success: @escaping (GetPersistedUserAvatarUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: GetPersistedUserAvatarUseCaseInput = GetPersistedUserAvatarUseCaseInput(dependenciesResolver: dependenciesEngine)
        let useCase: GetPersistedUserAvatarUseCase = self.dependenciesEngine.resolve(for: GetPersistedUserAvatarUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
    
    func getCurrentLanguage(_ success: @escaping (GetLanguagesUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let usecase: GetLanguagesUseCase = self.dependenciesEngine.resolve(for: GetLanguagesUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
    
    func updateCurrentLanguage(language: LanguageType, _ success: @escaping (UpdateLanguageUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let input: UpdateLanguageUseCaseInput = UpdateLanguageUseCaseInput(language: language)
        let usecase: UpdateLanguageUseCase = self.dependenciesEngine.resolve(for: UpdateLanguageUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: usecaseHandler, onSuccess: success, onError: failure)
    }
    
    func getUserPrefs(_ success: @escaping (GetPersonalAreaDataUseCaseOkOutput) -> Void, failure: @escaping (UseCaseError<StringErrorOutput>) -> Void) {
        let usecase: GetPersonalAreaDataUseCase = self.dependenciesEngine.resolve(for: GetPersonalAreaDataUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase,
                       useCaseHandler: usecaseHandler,
                       onSuccess: success,
                       onError: failure)
    }
    
    func updateUserPreferencesValues(userPrefEntity: UserPrefEntity, onSuccess: ((Void) -> Void)?, onError: ((UseCaseError<StringErrorOutput>) -> Void)?) {
        let input: UpdatePersonalAreaDataUseCaseInput = UpdatePersonalAreaDataUseCaseInput(dependenciesResolver: dependenciesEngine,
                                               userPref: userPrefEntity,
                                               userPreferencesDependencies: userPreferencesDependencies
        )
        let usecase: UpdatePersonalAreaDataUseCase = self.dependenciesEngine.resolve(for: UpdatePersonalAreaDataUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input),
                       useCaseHandler: usecaseHandler, onSuccess: onSuccess, onError: onError)
    }
    
    func getOTPPushDevice(_ success: @escaping (OTPPushDeviceEntity?) -> Void, failure: @escaping (String) -> Void) {
        let useCase: GetOTPPushDeviceUseCase = dependenciesEngine.resolve(for: GetOTPPushDeviceUseCase.self)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependenciesEngine.resolve(for: UseCaseHandler.self),
            onSuccess: { success($0.device) },
            onError: { [weak self] response in
                switch response {
                case .error(let error):
                    switch error?.codeError {
                    case .technicalError?, .differentsDevices?, .serviceFault?, .none:
                        failure(error?.getErrorDesc() ?? "")
                    case .unregisteredDevice?:
                        success(nil)
                    }
                    
                case .generic, .intern:
                    failure("generic_error_internetConnection")
                case .networkUnavailable:
                    failure("generic_error_needInternetConnection")
                case .unauthorized:
                    self?.dependenciesEngine.resolve(for: SessionResponseController.self).recivenUnauthorizedResponse()
                }
        })
    }
    
    func setUserAvatarImage(_ image: Data, onSuccess: ((Void) -> Void)?) {
        let input = SetPersistedUserAvatarUseCaseInput(dependenciesResolver: self.dependenciesEngine, image: image)
        let useCase: SetPersistedUserAvatarUseCase = self.dependenciesEngine.resolve(for: SetPersistedUserAvatarUseCase.self)
        let useCaseHandler: UseCaseHandler = dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: useCaseHandler, onSuccess: onSuccess)
    }
    
    func getAvailablePullOffers(_ locations: [PullOfferLocation], onSuccess: ((GetPullOffersUseCaseOutput?) -> Void)?) {
        let input = GetPullOffersUseCaseInput(locations: locations)
        let useCase = self.dependenciesEngine.resolve(for: GetPullOffersUseCase.self)
        let useCaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase.setRequestValues(requestValues: input), useCaseHandler: useCaseHandler, onSuccess: onSuccess)
    }
    
    func getUserBasicInfo(onSuccess success: @escaping (GetPersonalBasicInfoUseCaseOkOutput) -> Void, failure: ((String) -> Void)?) {
        let userPref = self.dependenciesEngine.resolve(for: UserPrefWrapper.self)
        let appConfigRepository = self.dependenciesEngine.resolve(for: AppConfigRepositoryProtocol.self)
        userPref.isPersonalAreaEnabled = appConfigRepository.getBool(PersonalAreaConstants.isPersonalAreaEnabled)
        guard userPref.isPersonalAreaEnabled == true else {
            return success(GetPersonalBasicInfoUseCaseOkOutput(personalInformation: nil))
        }
        let useCase = self.dependenciesEngine.resolve(firstTypeOf: GetPersonalBasicInfoUseCaseProtocol.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesEngine.resolve())
            .onSuccess {
                success($0)
            }
            .onError { error in
                failure?(error.getErrorDesc() ?? "generic_error_recoverData")
            }
    }
    
    func getOtherOperativesWrapper(locations: [PullOfferLocation], _ success: @escaping (GetOtherOperativesWrapperUseCaseOkOutput) -> Void) {
        let useCase: GetOtherOperativesWrapperUseCase = dependenciesEngine.resolve()
        UseCaseWrapper(
            with: useCase.setRequestValues(
                requestValues: GetOtherOperativesWrapperUseCaseInput(
                    locations: locations
                )
            ),
            useCaseHandler: dependenciesEngine.resolve(),
            onSuccess: success
        )
    }
    
    func updateUserPref(_ userPref: UserPrefWrapper) {
        self.userPref = userPref
    }
    
    public func loadPersonalAreaPreferences(_ completion: @escaping () -> Void) {
        self.getUserPrefs({ [weak self] (response) in
            guard let self = self else { return }
            self.userPref.username = response.userName ?? ""
            self.userPref.userNameWithoutSurname = response.userNameWithoutSurname
            self.userPref.userCompleteName = response.userCompleteName
            self.userPref.currentPhotoTheme = response.userPrefEntity?.photoThemePersonalAreaSelected()
            self.userPref.currentPG = response.userPrefEntity?.globalPositionOnboardingSelected().rawValue
            self.userPref.currentLanguage = response.currentLanguage
            self.userPref.isDiscretModeActivated = response.userPrefEntity?.isDiscretModeActivated()
            self.userPref.isChartModeActivated = response.userPrefEntity?.isChartModeActivated()
            self.userPref.isOperativeUser = !response.isConsultiveUser
            self.userPref.digitalProfilePercentage = response.digitalProfilePercentage
            self.userPref.isPersonalDocEnabled = response.isPersonalDocEnabled
            self.userPref.isOtpPushEnabled = response.isOtpPushEnabled
            self.userPref.isAppInfoEnabled = response.isAppInfoEnabled
            self.userPref.digitalProfileType = response.digitalProfileType
            self.userPref.userAlias =
                (response.userPrefEntity?.getUserAlias() ?? "").isEmpty ?
                    response.userNameWithoutSurname?.camelCasedString : (response.userPrefEntity?.getUserAlias() ?? "")
            self.userPref.isGeolocalizationEnabled = self.locationPermissionManager?.isLocationAccessEnabled()
            self.userPref.userPrefEntity = response.userPrefEntity
            self.userPref.loginType = response.loginType
            self.userPref.isEnabledDigitalProfileView = self.localAppConfig.isEnabledDigitalProfileView
            self.userPref.isPersonalAreaSecuritySettingEnabled = response.isPersonalAreaSecuritySettingEnabled
            let appConfigRepository = self.dependenciesEngine.resolve(for: AppConfigRepositoryProtocol.self)
            self.userPref.isPersonalAreaEnabled = appConfigRepository.getBool(PersonalAreaConstants.isPersonalAreaEnabled)
            completion()
            }, failure: { _ in
                completion()
        })
    }

    func getPermissions(_ success: @escaping (GetPermissionsUseCaseOkOutput) -> Void) {
        let usecase: GetPermissionsUseCase = self.dependenciesEngine.resolve(for: GetPermissionsUseCase.self)
        let usecaseHandler: UseCaseHandler = self.dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, onSuccess: success)
    }
}
