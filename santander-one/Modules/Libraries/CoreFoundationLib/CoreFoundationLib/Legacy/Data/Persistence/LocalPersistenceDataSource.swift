import Foundation
import CoreDomain

public final class LocalPersistenceDataSource: PersistenceDataSource {
    private let daoPersistedUser: DAOPersistedUserProtocol
    private let daoSharedPersistedUser: DAOSharedPersistedUserProtocol
    private let daoUserPref: DAOUserPref
    private let daoUserPrefEntity: DAOUserPrefEntityProtocol
    private let daoSharedUserPrefEntity: DAOSharedUserPrefEntityProtocol
    private let daoPersistedUserAvatar: DAOPersistedUserAvatar
    private let daoPublicFilesEnvironment: DAOPublicFilesEnvironment
    private let daoInbentaEnvironment: DAOInbentaEnvironment
    private let daoLanguage: DAOLanguage

    public init(daoPersistedUser: DAOPersistedUserProtocol,
         daoSharedPersistedUser: DAOSharedPersistedUserProtocol,
         daoUserPref: DAOUserPref,
         daoUserPrefEntity: DAOUserPrefEntityProtocol,
         daoSharedUserPrefEntity: DAOSharedUserPrefEntityProtocol,
         daoPublicFilesEnvironment: DAOPublicFilesEnvironment,
         daoInbentaEnvironment: DAOInbentaEnvironment,
         daoPersistedUserAvatar: DAOPersistedUserAvatar,
         daoLanguage: DAOLanguage) {
        self.daoPersistedUser = daoPersistedUser
        self.daoSharedPersistedUser = daoSharedPersistedUser
        self.daoUserPref = daoUserPref
        self.daoUserPrefEntity = daoUserPrefEntity
        self.daoSharedUserPrefEntity = daoSharedUserPrefEntity
        self.daoPublicFilesEnvironment = daoPublicFilesEnvironment
        self.daoInbentaEnvironment = daoInbentaEnvironment
        self.daoPersistedUserAvatar = daoPersistedUserAvatar
        self.daoLanguage = daoLanguage
    }
}

public extension LocalPersistenceDataSource {
    
    func getPersistedLanguage() -> LanguageType? {
        objc_sync_enter(daoLanguage)
        let appLanguage = daoLanguage.get()
        objc_sync_exit(daoLanguage)
        return appLanguage
    }
    
    func setPersistedLanguage(language: LanguageType) {
        objc_sync_enter(daoLanguage)
        _ = daoLanguage.set(language: language)
        objc_sync_exit(daoLanguage)
    }
    
    func getPersistedUserAvatar(userId: String) -> Data? {
        objc_sync_enter(daoPersistedUserAvatar)
        let avatar = daoPersistedUserAvatar.get(userId: userId)
        objc_sync_exit(daoPersistedUserAvatar)
        return avatar
    }
    
    func setPersistedUserAvatar(userId: String, image: Data) {
        objc_sync_enter(daoPersistedUserAvatar)
        _ = daoPersistedUserAvatar.set(userId: userId, image: image)
        objc_sync_exit(daoPersistedUserAvatar)
    }

    func getPersistedUser() -> PersistedUserDTO? {
        objc_sync_enter(daoPersistedUser)
        let persistedUser = daoPersistedUser.get()
        objc_sync_exit(daoPersistedUser)
        return persistedUser
    }

    func setPersistedUser(persistedUser: PersistedUserDTO) {
        objc_sync_enter(daoPersistedUser)
        _ = daoPersistedUser.set(persistedUser: persistedUser)
        objc_sync_exit(daoPersistedUser)
    }

    func removePersistedUser() {
        objc_sync_enter(daoPersistedUser)
        _ = daoPersistedUser.remove()
        objc_sync_exit(daoPersistedUser)
    }
    
    func getSharedPersistedUser() -> SharedPersistedUserDTO? {
        objc_sync_enter(daoSharedPersistedUser)
        let persistedUser = daoSharedPersistedUser.get()
        objc_sync_exit(daoSharedPersistedUser)
        return persistedUser
        
    }
    
    func setSharedPersistedUser(persistedUser: SharedPersistedUserDTO) {
        objc_sync_enter(daoSharedPersistedUser)
        _ = daoSharedPersistedUser.set(persistedUser: persistedUser)
        objc_sync_exit(daoSharedPersistedUser)
    }
    
    func removeSharedPersistedUser() {
        objc_sync_enter(daoSharedPersistedUser)
        _ = daoSharedPersistedUser.remove()
        objc_sync_exit(daoSharedPersistedUser)
    }
    
    func getSharedUserPrefEntity(userId: String) -> SharedUserPrefDTOEntity? {
        objc_sync_enter(daoSharedUserPrefEntity)
        let user = daoSharedUserPrefEntity.get().getSharedUserPrefEntity(userId: userId)
        objc_sync_exit(daoSharedUserPrefEntity)
        return user
    }
    
    func setSharedUserPrefEntity(userPref: SharedUserPrefDTOEntity) {
        objc_sync_enter(daoSharedUserPrefEntity)
        let userPrefs = daoSharedUserPrefEntity.get()
        userPrefs.setSharedUserPrefEntity(userPrefDTO: userPref)
        _ = daoSharedUserPrefEntity.set(userPrefs: userPrefs)
        objc_sync_exit(daoSharedUserPrefEntity)
    }
    
    func removeSharedUserPrefEntity() {
        objc_sync_enter(daoSharedUserPrefEntity)
        _ = daoSharedUserPrefEntity.remove()
        objc_sync_exit(daoSharedUserPrefEntity)
    }

    func getUserPref(userId: String) -> UserPrefDTO {
        objc_sync_enter(daoUserPref)
        let user = daoUserPref.get().getUserPrefDTO(userId: userId)
        objc_sync_exit(daoUserPref)
        return user
    }

    func setUserPref(userPrefDTO: UserPrefDTO) {
        objc_sync_enter(daoUserPref)
        let userPrefs = daoUserPref.get()
        userPrefs.setUserPrefDTO(userPrefDTO: userPrefDTO)
        _ = daoUserPref.set(userPrefs: userPrefs)
        objc_sync_exit(daoUserPref)
    }
    
    func setUserPrefEntity(userPrefDTOEntity: UserPrefDTOEntity) {
        objc_sync_enter(daoUserPrefEntity)
        let userPrefs = daoUserPrefEntity.get()
        userPrefs.setUserPrefDTO(userPrefDTO: userPrefDTOEntity)
        _ = daoUserPrefEntity.set(userPrefs: userPrefs)
        objc_sync_exit(daoUserPrefEntity)
    }
    
    func getUserPrefEntity(userId: String) -> UserPrefDTOEntity {
        objc_sync_enter(daoUserPrefEntity)
        let user = daoUserPrefEntity.get().getUserPrefDTO(userId: userId)
        objc_sync_exit(daoUserPrefEntity)
        return user
    }
    
    func isUserPrefEntity(userId: String) -> Bool {
        objc_sync_enter(daoUserPrefEntity)
        let isUser = daoUserPrefEntity.get().isUserPrefDTO(userId: userId)
        objc_sync_exit(daoUserPrefEntity)
        return isUser
    }
    
    func getIfExistsUserPrefEntity(userId: String) -> UserPrefDTOEntity? {
        objc_sync_enter(daoUserPrefEntity)
        let user = daoUserPrefEntity.get().getIfExistsUserPrefDTO(userId: userId)
        objc_sync_exit(daoUserPrefEntity)
        return user
    }

    func getPublicFilesEnvironmentDTO() -> PublicFilesEnvironmentDTO? {
        objc_sync_enter(daoPublicFilesEnvironment)
        let publicFilesEnvironment = daoPublicFilesEnvironment.get()
        objc_sync_exit(daoPublicFilesEnvironment)
        return publicFilesEnvironment
    }

    func setPublicFilesEnvironmentDTO(publicFilesEnvironmentDTO: PublicFilesEnvironmentDTO) {
        objc_sync_enter(daoPublicFilesEnvironment)
        _ = daoPublicFilesEnvironment.set(publicFilesEnvironmentDTO: publicFilesEnvironmentDTO)
        objc_sync_exit(daoPublicFilesEnvironment)
    }

    func getInbentaEnvironmentDTO() -> InbentaEnvironmentDTO? {
        objc_sync_enter(daoInbentaEnvironment)
        let inbentaEnvironment = daoInbentaEnvironment.get()
        objc_sync_exit(daoInbentaEnvironment)
        return inbentaEnvironment
    }

    func setInbentaEnvironmentDTO(inbentaEnvironmentDTO: InbentaEnvironmentDTO) {
        objc_sync_enter(daoInbentaEnvironment)
        _ = daoInbentaEnvironment.set(inbentaEnvironmentDTO: inbentaEnvironmentDTO)
        objc_sync_exit(daoInbentaEnvironment)
    }
    
    func isCoachmarkShown(userId: String, coachmarkId: CoachmarkIdentifier) -> Bool {
        let userPrefDTO = getUserPref(userId: userId)
        objc_sync_enter(daoUserPref)
        let output = userPrefDTO.coachmarksPref.contains(coachmarkId.rawValue)
        objc_sync_exit(daoUserPref)
        return output
    }
    
    func setCoachmarkShown(userId: String, coachmarkId: [CoachmarkIdentifier]) {
        let userPrefDTO = getUserPref(userId: userId)
        objc_sync_enter(daoUserPref)
        for id in coachmarkId {
            if !userPrefDTO.coachmarksPref.contains(id.rawValue) {
                userPrefDTO.coachmarksPref.append(id.rawValue)
            }
        }
        objc_sync_exit(daoUserPref)
        setUserPref(userPrefDTO: userPrefDTO)
    }
}
