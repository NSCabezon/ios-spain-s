import SANLegacyLibrary
import OpenCombine
import Foundation

public protocol AppRepositoryProtocol: AnyObject {
    // MARK: Locale //
    func getPersistedUser() -> RepositoryResponse<PersistedUserDTO>
    func getSharedPersistedUser() -> SharedPersistedUserDTOProtocol?
    func getUserPreferences(userId: String) -> UserPrefDTOEntity
    func setUserPreferences(userPref: UserPrefDTOEntity)
    func getSharedUserPreferences(userId: String) -> SharedUserPrefDTOEntity?
    func setSharedUserPref(userId: String)
    func getCurrentLanguage() -> LanguageType
    func changeLanguage(language: LanguageType)
    func getPersistedUserAvatar(userId: String) -> Data?
    func getReactivePersistedUserAvatar(userId: String) -> AnyPublisher<Data?, Never>
    func setPersistedUserAvatar(userId: String, image: Data)
    func getSecurityTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getSecurityTravelTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getHelpCenterTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getAtmTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getActivateCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getActivateDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getCardBoardingWelcomeCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getCardBoardingWelcomeDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getSantanderExperiences() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getCurrentPublicFilesEnvironment() -> RepositoryResponse<PublicFilesEnvironmentDTO>
    func getPendingSolicitudesClosed() -> RepositoryResponse<[PendingSolicitudeEntity]>
    func setPendingSolicitudeClosed(_ pendingSolicitude: PendingSolicitudeEntity)
    func isSessionEnabled() -> RepositoryResponse<Bool>
    func getLanguage() -> RepositoryResponse<LanguageType?>
    func getCardboardingAlmostDoneCreditTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func getCardboardingAlmostDoneDebitTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func startSession() -> RepositoryResponse<Void>
    func closeSession() -> RepositoryResponse<Void>
    func removePersistedUser() -> RepositoryResponse<Void>
    func setPersistedUserDTO(persistedUserDTO: PersistedUserDTO) -> RepositoryResponse<Void>
    // MARK: Temporary variables to persist user when activating TouchId at personal data
    func getTempLogin() -> RepositoryResponse<String>
    func getTempUserType() -> RepositoryResponse<UserLoginType>
    func getTempEnvironmentName() -> RepositoryResponse<String>
    func getTempName() -> RepositoryResponse<String>
    func setTempLogin(tempLogin: String) -> RepositoryResponse<Void>
    func setTempUserType(userType: UserLoginType) -> RepositoryResponse<Void>
    func setTempEnvironmentName(tempEnvironmentName: String) -> RepositoryResponse<Void>
    func setTempName(name: String) -> RepositoryResponse<Void>
    func hasPersistedUser() -> RepositoryResponse<Bool>
    func isMixedUser() -> RepositoryResponse<Bool>
    func setMixedUsed(isMixedUser: Bool) -> RepositoryResponse<Void>
    func setUserPrefPb(isPB: Bool, userId: String) -> RepositoryResponse<Void>
    
    // MARK: - Tips
    func getTips() -> RepositoryResponse<[PullOfferTipEntity]?>
    func setTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void>
    func setSecurityTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void>
    func setSecurityTravelTips(tips: [PullOfferTipEntity]? )-> RepositoryResponse<Void>
    func setHelpCenterTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void>
    func setAtmTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void>
    func setActivateCreditCardTips(tips: [PullOfferTipEntity]?)
    func setActivateDebitCardTips(tips: [PullOfferTipEntity]?)
    func setCardBoardingWelcomeCreditCardTips(tips: [PullOfferTipEntity]?)
    func setCardBoardingWelcomeDebitCardTips(tips: [PullOfferTipEntity]?)
    func setSantander(experiences: [PullOfferTipEntity]?) -> RepositoryResponse<Void>
    func setCardboardingAlmostDoneDebitTips(tips: [PullOfferTipEntity]?)
    func setCardboardingAlmostDoneCreditTips(tips: [PullOfferTipEntity]?)
    
    // MARK: - Segments
    
    func getCommercialSegment() -> RepositoryResponse<CommercialSegmentEntity>
    func setCommercialSegment(segment: CommercialSegmentEntity) -> RepositoryResponse<Void>

    func getReactiveUserPreferences(userId: String) -> AnyPublisher<UserPrefDTOEntity, Error>
    func getReactivePublicFileURL() -> AnyPublisher<URL, Error>
    func getPersistedUserAvatarPublisher(userId: String) -> AnyPublisher<Data?, Never>
    func setReactivePersistedUserAvatar(userId: String, data: Data) -> AnyPublisher<Bool, Never>
}
