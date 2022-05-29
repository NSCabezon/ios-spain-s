import CoreFoundationLib
import SANLegacyLibrary

final class GetLoginMessagesContextUseCase: LocalAuthLoginDataUseCase<Void, GetLoginMessagesContextUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let provider: BSANManagersProvider
    private let pullOffersInterpreter: PullOffersInterpreter
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(appRepository: AppRepository, dependenciesResolver: DependenciesResolver) {
        self.appRepository = appRepository
        self.provider = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.dependenciesResolver = dependenciesResolver
        super.init(dependenciesResolver: dependenciesResolver)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoginMessagesContextUseCaseOkOutput, StringErrorOutput> {
        guard
            let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition()),
            let checkings = try appRepository.getLoginMessagesCheckings().getResponseData()
            else {
                return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let userId = GlobalPosition.createFrom(dto: globalPositionDTO).userId
        let userPrefEntity = getUserPref(userId)
        var context = LoginMessagesContext(userPref: userPrefEntity)
        context.isOnboardingDisabled = appConfigRepository
            .getBool(DomainConstant.appConfigDisableOnboarding) ?? false
        context.loginMessagesCheckings = checkings
        context.enableOtpPush = appConfigRepository
            .getBool(DomainConstant.appConfigEnableOtpPush) ?? false
        context.messageOtpPushBeta = appConfigRepository
            .getBool(DomainConstant.appConfigMessageOtpPushBeta) ?? false
        context.isFirstTimeBiometricCredentialActivated = userPrefEntity.getFirstTimeBiometricCredentialActivated()
        if let offerDTO = pullOffersInterpreter.getCandidate(userId: userId, location: PullOfferLocation.TUTORIAL) {
            context.tutorialOffer = Offer(offerDTO: offerDTO)
        }
        if let offerDTO = pullOffersInterpreter.getCandidate(userId: userId, location: PullOfferLocation.TUTORIAL_BEFORE_ONBOARDING) {
            context.tutorialBeforeOnboardingOffer = Offer(offerDTO: offerDTO)
        }
        if let offerDTO = pullOffersInterpreter.getCandidate(userId: userId, location: PullOfferLocation.PG_FLOATING_BANNER) {
            context.floatingBannerOffer = Offer(offerDTO: offerDTO)
        }
        let appConfigWhatsNew = appConfigRepository
            .getBool(DomainConstant.enabledWhatsNew) ?? false
        context.isWhatsNewEnabled = appConfigWhatsNew && userPrefEntity.isWhatsNewBubbleEnabled()
        let appConfigNeedUpdatePassword = appConfigRepository
            .getBool(DomainConstant.forceUpdateKeys) ?? false
        let needUpdatePasswordConfiguration = dependenciesResolver.resolve(forOptionalType: SetNeedUpdatePasswordConfiguration.self)
        context.needUpdatePassword = appConfigNeedUpdatePassword && (needUpdatePasswordConfiguration?.forceToUpdatePassword ?? false)
        return UseCaseResponse.ok(GetLoginMessagesContextUseCaseOkOutput(context: context))
    }
}
 
private extension GetLoginMessagesContextUseCase {
    func getUserPref(_ userId: String) -> UserPrefEntity {
        let userPreferences = appRepository.getUserPreferences(userId: userId)
        let userPrefEntity = UserPrefEntity.from(dto: userPreferences)
        let onboardingVersion = appConfigRepository.getInt(DomainConstant.appConfigOnboardingVersion) ?? 1
        if let userPrefOnboardingVersion = userPreferences.pgUserPrefDTO.onboardingVersion {
            if userPrefOnboardingVersion < onboardingVersion {
                userPreferences.pgUserPrefDTO.onboardingVersion = onboardingVersion
                userPreferences.pgUserPrefDTO.onboardingFinished = false
                userPreferences.pgUserPrefDTO.onboardingCancelled = false
                _ = appRepository.setUserPreferences(userPref: userPreferences)
            }
        } else {
            userPreferences.pgUserPrefDTO.onboardingVersion = onboardingVersion
            _ = appRepository.setUserPreferences(userPref: userPreferences)
        }
        return userPrefEntity
    }
}

struct GetLoginMessagesContextUseCaseOkOutput {
    let context: LoginMessagesContext
}
