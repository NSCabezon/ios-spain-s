

public protocol DAOSharedPersistedUserProtocol {
    func remove() -> Bool
    func set(persistedUser: SharedPersistedUserDTO) -> Bool
    func get() -> SharedPersistedUserDTO?
}
