import Foundation
import CoreDomain

public protocol PersistenceDataSource: PersistenceDataSourceProtocol {
    
    func setPersistedUser(persistedUser: PersistedUserDTO)
    func removePersistedUser()
    
    func getSharedPersistedUser() -> SharedPersistedUserDTO?
    func setSharedPersistedUser(persistedUser: SharedPersistedUserDTO)
    func removeSharedPersistedUser()
    
    func getPersistedUserAvatar(userId: String) -> Data?
    func setPersistedUserAvatar(userId: String, image: Data)

    func getUserPref(userId: String) -> UserPrefDTO
    func setUserPref(userPrefDTO: UserPrefDTO)
    
    func isUserPrefEntity(userId: String) -> Bool
    func getIfExistsUserPrefEntity(userId: String) -> UserPrefDTOEntity?
    
    func getSharedUserPrefEntity(userId: String) -> SharedUserPrefDTOEntity?
    func setSharedUserPrefEntity(userPref: SharedUserPrefDTOEntity)
    func removeSharedUserPrefEntity()

    func getPublicFilesEnvironmentDTO() -> PublicFilesEnvironmentDTO?
    func setPublicFilesEnvironmentDTO(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO)

    func getInbentaEnvironmentDTO() -> InbentaEnvironmentDTO?
    func setInbentaEnvironmentDTO(inbentaEnvironmentDTO: InbentaEnvironmentDTO)
    
    func getPersistedLanguage() -> LanguageType?
    func setPersistedLanguage(language: LanguageType)
    
    func isCoachmarkShown(userId: String, coachmarkId: CoachmarkIdentifier) -> Bool
    func setCoachmarkShown(userId: String, coachmarkId: [CoachmarkIdentifier])
}
