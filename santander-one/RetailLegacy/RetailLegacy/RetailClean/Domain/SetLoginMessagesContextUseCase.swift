import CoreFoundationLib
import SANLegacyLibrary

final class SetLoginMessagesContextUseCase: UseCase<SetLoginMessagesContextUseCaseInput, Void, StringErrorOutput> {
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: SetLoginMessagesContextUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        guard let context = requestValues.context
            else { return .error(StringErrorOutput(nil)) }
        updateFirstLoginUserPrefFields(context)
        _ = appRepository.setLoginMessages(checkings: context.loginMessagesCheckings)
        return UseCaseResponse.ok()
    }
}

private extension SetLoginMessagesContextUseCase {
    func updateFirstLoginUserPrefFields(_ context: LoginMessagesContext?) {
        guard let userId = context?.userPref.userId,
            let contextUserPref = context?.userPref.userPrefDTOEntity.pgUserPrefDTO else { return }
        let userPrefDTO = appRepository.getUserPreferences(userId: userId)
        guard self.checkWillHaveToUpdateUserPrefDTO(userPrefDTO, with: contextUserPref) else {
            return
        }
        userPrefDTO.pgUserPrefDTO.isFirstTimeBiometricCredentialActivated = contextUserPref.isFirstTimeBiometricCredentialActivated
        userPrefDTO.pgUserPrefDTO.askedForBiometricPermissions = contextUserPref.askedForBiometricPermissions
        userPrefDTO.pgUserPrefDTO.whatsNewCounter = contextUserPref.whatsNewCounter
        userPrefDTO.pgUserPrefDTO.whatsNewBigBubbleVisibled = contextUserPref.whatsNewBigBubbleVisibled
        userPrefDTO.pgUserPrefDTO.touchOrFaceIdProfileSaved = contextUserPref.touchOrFaceIdProfileSaved
        userPrefDTO.pgUserPrefDTO.pushNotificationProfileSaved = contextUserPref.pushNotificationProfileSaved
        userPrefDTO.pgUserPrefDTO.geolocalizationProfileSaved = contextUserPref.geolocalizationProfileSaved
        userPrefDTO.pgUserPrefDTO.transitiveAppIcon = contextUserPref.transitiveAppIcon
        userPrefDTO.pgUserPrefDTO.onboardingFinished = contextUserPref.onboardingFinished
        userPrefDTO.pgUserPrefDTO.onboardingCancelled = contextUserPref.onboardingCancelled
        appRepository.setUserPreferences(userPref: userPrefDTO)
    }
    
    func checkWillHaveToUpdateUserPrefDTO(_ userPrefDTO: UserPrefDTOEntity, with contextUserPref: PGUserPrefDTOEntity) -> Bool {
        return userPrefDTO.pgUserPrefDTO.isFirstTimeBiometricCredentialActivated != contextUserPref.isFirstTimeBiometricCredentialActivated ||
        userPrefDTO.pgUserPrefDTO.askedForBiometricPermissions != contextUserPref.askedForBiometricPermissions ||
        userPrefDTO.pgUserPrefDTO.whatsNewCounter != contextUserPref.whatsNewCounter ||
        userPrefDTO.pgUserPrefDTO.whatsNewBigBubbleVisibled != contextUserPref.whatsNewBigBubbleVisibled ||
        userPrefDTO.pgUserPrefDTO.touchOrFaceIdProfileSaved != contextUserPref.touchOrFaceIdProfileSaved ||
        userPrefDTO.pgUserPrefDTO.pushNotificationProfileSaved != contextUserPref.pushNotificationProfileSaved ||
        userPrefDTO.pgUserPrefDTO.geolocalizationProfileSaved != contextUserPref.geolocalizationProfileSaved ||
        userPrefDTO.pgUserPrefDTO.transitiveAppIcon != contextUserPref.transitiveAppIcon ||
        userPrefDTO.pgUserPrefDTO.onboardingFinished != contextUserPref.onboardingFinished ||
        userPrefDTO.pgUserPrefDTO.onboardingCancelled != contextUserPref.onboardingCancelled
    }
}

struct SetLoginMessagesContextUseCaseInput {
    let context: LoginMessagesContext?
}
