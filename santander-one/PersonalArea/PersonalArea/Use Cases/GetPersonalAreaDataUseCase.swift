import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

final class GetPersonalAreaDataUseCase: UseCase<Void, GetPersonalAreaDataUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersonalAreaDataUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let configuration: PersonalAreaConfiguration = self.dependenciesResolver.resolve(for: PersonalAreaConfiguration.self)
        let appRepositoryProtocol: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let response = try provider.getBsanSignatureManager().getCMCSignature()
        let data = response.isSuccess() ? try response.getResponseData() : nil
        let userPref = appRepositoryProtocol.getUserPreferences(userId: globalPosition.userId ?? "")
        let applePayEnrollmentManager = self.dependenciesResolver.resolve(for: ApplePayEnrollmentManagerProtocol.self)
        let input = DigitalProfileExecutorWrapperInput(globalPosition: globalPosition,
                                                       provider: provider,
                                                       pushNotificationPermissionsManager: configuration.pushNotificationPermissionsManager,
                                                       locationPermissionsManager: configuration.locationPermissionsManager,
                                                       localAuthPermissionsManager: configuration.localAuthPermissionsManager,
                                                       appRepositoryProtocol: appRepositoryProtocol,
                                                       appConfigRepository: appConfigRepository,
                                                       applePayEnrollmentManager: applePayEnrollmentManager,
                                                       dependenciesResolver: dependenciesResolver)
        let digitalProfileWrapper = DigitalProfileExecutorWrapper(input: input)
        let digitalProfileResponse = try digitalProfileWrapper.execute()
        let loginType = try? appRepositoryProtocol.getPersistedUser().getResponseData()?.loginType
        let isPersonalAreaSecuritySettingEnabled = appConfigRepository.getBool(PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled)
        return UseCaseResponse.ok(GetPersonalAreaDataUseCaseOkOutput(userName: globalPosition.availableName,
                                                                     userNameWithoutSurname: globalPosition.clientNameWithoutSurname,
                                                                     userCompleteName: "\(globalPosition.clientNameWithoutSurname ?? "") \(globalPosition.clientBothSurnames ?? "")",
                                                                     userPrefEntity: UserPrefEntity.from(dto: userPref),
                                                                     currentLanguage: appRepositoryProtocol.getCurrentLanguage(),
                                                                     isConsultiveUser: isConsultiveUser(signatureStatusInfo: data),
                                                                     digitalProfilePercentage: digitalProfileResponse.percentage,
                                                                     digitalProfileType: digitalProfileResponse.category,
                                                                     isPersonalDocEnabled: appConfigRepository.getBool("enablePersonaldoc") ?? false,
                                                                     isOtpPushEnabled: appConfigRepository.getBool("enableOtpPush") ?? false,
                                                                     isAppInfoEnabled: appConfigRepository.getBool("enableAppInfo") ?? false,
                                                                     loginType: loginType?.type,
                                                                     isPersonalAreaSecuritySettingEnabled: isPersonalAreaSecuritySettingEnabled)
        )
    }
    
    private func isConsultiveUser(signatureStatusInfo: SignStatusInfo?) -> Bool {
        guard let info = signatureStatusInfo else {
            return false
        }
        return info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "C"
    }
}

struct GetPersonalAreaDataUseCaseOkOutput {
    let userName: String?
    let userNameWithoutSurname: String?
    let userCompleteName: String?
    let userPrefEntity: UserPrefEntity?
    let currentLanguage: LanguageType
    let isConsultiveUser: Bool
    let digitalProfilePercentage: Double
    let digitalProfileType: DigitalProfileEnum
    let isPersonalDocEnabled: Bool
    let isOtpPushEnabled: Bool
    let isAppInfoEnabled: Bool
    let loginType: String?
    let isPersonalAreaSecuritySettingEnabled: Bool?
}
