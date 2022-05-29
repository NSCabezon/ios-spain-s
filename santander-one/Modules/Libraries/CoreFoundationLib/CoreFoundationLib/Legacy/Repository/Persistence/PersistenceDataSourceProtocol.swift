import Foundation

public protocol PersistenceDataSourceProtocol: UserPrefEntityPersistenceDataSource, PersistedUserPersistenceDataSource {}

public protocol UserPrefEntityPersistenceDataSource {
    func getUserPrefEntity(userId: String) -> UserPrefDTOEntity
    func setUserPrefEntity(userPrefDTOEntity: UserPrefDTOEntity)
}

public protocol PersistedUserPersistenceDataSource {
    func getPersistedUser() -> PersistedUserDTO?
}
