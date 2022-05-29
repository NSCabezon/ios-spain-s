//
//  AppRepositoryMock.swift
//  CoreTestData
//
//  Created by Juan Carlos López Robles on 2/24/22.
//

import OpenCombine
import CoreFoundationLib
import SANLegacyLibrary

public final class AppRepositoryMock: AppRepositoryProtocol {
    public var welcomeCreditCardTips: [PullOfferTipEntity]?
    public var welcomeDebitCardTips: [PullOfferTipEntity]?
    public var persistedUser: PersistedUserDTO? = nil
    public var userPref: UserPrefDTOEntity? = nil
    public var publicFilesEnvironment = PublicFilesEnvironmentDTO("testName", "testUrlBase", true)
    
    public init() { }
    
    public func getCardBoardingWelcomeCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock(welcomeCreditCardTips)
    }
    
    public func getCardBoardingWelcomeDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock(welcomeDebitCardTips)
    }
    
    public func getActivateCreditCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getActivateDebitCardTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getCardboardingAlmostDoneCreditTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getCardboardingAlmostDoneDebitTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getSharedUserPreferences(userId: String) -> SharedUserPrefDTOEntity? {
        return nil
    }
    
    public func setSharedUserPref(userId: String) {
        
    }
    
    public func getAtmTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getSantanderExperiences() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getLanguage() -> RepositoryResponse<LanguageType?> {
        return RepositoryResponseMock(.spanish)
    }
    
    public func getPersistedUser() -> RepositoryResponse<PersistedUserDTO> {
        return RepositoryResponseMock(persistedUser)
    }
    
    public func getSharedPersistedUser() -> SharedPersistedUserDTOProtocol? {
        return nil
    }
    
    public func getSecurityTravelTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getPendingSolicitudesClosed() -> RepositoryResponse<[PendingSolicitudeEntity]> {
        return RepositoryResponseMock()
    }
    
    public func setPendingSolicitudeClosed(_ pendingSolicitude: PendingSolicitudeEntity) {
        
    }
    
    public func isSessionEnabled() -> RepositoryResponse<Bool> {
        return RepositoryResponseMock()
    }
    
    public func getHelpCenterTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func getCurrentPublicFilesEnvironment() -> RepositoryResponse<PublicFilesEnvironmentDTO> {
        return RepositoryResponseMock(self.publicFilesEnvironment)
    }
    
    public func getCommercialSegment() -> RepositoryResponse<CommercialSegmentEntity> {
        return RepositoryResponseMock()
    }
    
    public func getSecurityTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock()
    }
    
    public func isTipsEmpty() -> Bool {
        return false
    }
    
    public func getCurrentLanguage() -> LanguageType {
        return LanguageType.spanish
    }
    
    public func changeLanguage(language: LanguageType) {}
    
    public func getUserPreferences(userId: String) -> UserPrefDTOEntity {
        guard let userPref = self.userPref else {
            return UserPrefDTOEntity(userId: userId)
        }
        return userPref
    }
    
    public func setUserPreferences(userPref: UserPrefDTOEntity) {
        self.userPref = userPref
    }
    
    public func getPersistedUserAvatar(userId: String) -> Data? {
        return nil
    }
    
    public func getReactivePersistedUserAvatar(userId: String) -> AnyPublisher<Data?, Never> {
        let userAvatar: Data? = Data(userId.utf8)
        return Just(userAvatar)
            .compactMap { image -> Data? in
                return image ?? userAvatar
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    public func setPersistedUserAvatar(userId: String, image: Data) {
    }
    
    public func startSession() -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func closeSession() -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func removePersistedUser() -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setPersistedUserDTO(persistedUserDTO: PersistedUserDTO) -> RepositoryResponse<Void> {
        self.persistedUser = persistedUserDTO
        return RepositoryResponseMock()
    }
    
    public func getTempLogin() -> RepositoryResponse<String> {
        return RepositoryResponseMock()
    }
    
    public func getTempUserType() -> RepositoryResponse<UserLoginType> {
        return RepositoryResponseMock()
    }
    
    public func getTempEnvironmentName() -> RepositoryResponse<String> {
        return RepositoryResponseMock()
    }
    
    public func getTempName() -> RepositoryResponse<String> {
        return RepositoryResponseMock()
    }
    
    public func setTempLogin(tempLogin: String) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setTempUserType(userType: UserLoginType) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setTempEnvironmentName(tempEnvironmentName: String) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setTempName(name: String) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func hasPersistedUser() -> RepositoryResponse<Bool> {
        return RepositoryResponseMock(persistedUser != nil)
    }
    
    public func isMixedUser() -> RepositoryResponse<Bool> {
        return RepositoryResponseMock(true)
    }
    
    public func setMixedUsed(isMixedUser: Bool) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func getTips() -> RepositoryResponse<[PullOfferTipEntity]?> {
        return RepositoryResponseMock(nil)
    }
    
    public func setTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setSecurityTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setSecurityTravelTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setHelpCenterTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setAtmTips(tips: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setActivateCreditCardTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setActivateDebitCardTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setCardBoardingWelcomeCreditCardTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setCardBoardingWelcomeDebitCardTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setSantander(experiences: [PullOfferTipEntity]?) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setCardboardingAlmostDoneDebitTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setCardboardingAlmostDoneCreditTips(tips: [PullOfferTipEntity]?) {
        
    }
    
    public func setUserPrefPb(isPB: Bool, userId: String) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func setCommercialSegment(segment: CommercialSegmentEntity) -> RepositoryResponse<Void> {
        return RepositoryResponseMock()
    }
    
    public func getReactiveUserPreferences(userId: String) -> AnyPublisher<UserPrefDTOEntity, Error> {
        return Just(
            {
                guard let userPref = self.userPref else {
                    return UserPrefDTOEntity(userId: userId)
                }
                return userPref
            }()
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    public func getReactivePublicFileURL() -> AnyPublisher<URL, Error> {
        guard let publicUrl = URL(string: "stringUrl") else {
            return Fail(error: NSError(description: "Invalid url")).eraseToAnyPublisher()
        }
        return Just(publicUrl).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    public func getPersistedUserAvatarPublisher(userId: String) -> AnyPublisher<Data?, Never> {
        return Just(self.getPersistedUserAvatar(userId: userId)).eraseToAnyPublisher()
    }
    
    public func setReactivePersistedUserAvatar(userId: String, data: Data) -> AnyPublisher<Bool, Never> {
        setPersistedUserAvatar(userId: userId, image: data)
        return Just(true).eraseToAnyPublisher()
    }
}
