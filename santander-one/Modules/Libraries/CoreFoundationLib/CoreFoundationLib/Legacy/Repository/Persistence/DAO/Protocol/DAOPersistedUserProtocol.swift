

public protocol DAOPersistedUserProtocol {
    func remove() -> Bool
    func set(persistedUser: PersistedUserDTO) -> Bool
    func get() -> PersistedUserDTO?
}
