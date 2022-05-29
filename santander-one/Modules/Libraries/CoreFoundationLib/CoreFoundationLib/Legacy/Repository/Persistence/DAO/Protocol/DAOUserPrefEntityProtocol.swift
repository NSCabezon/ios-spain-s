

public protocol DAOUserPrefEntityProtocol {
    func remove() -> Bool
    func set(userPrefs: UserPrefDictEntity) -> Bool
    func get() -> UserPrefDictEntity
}
