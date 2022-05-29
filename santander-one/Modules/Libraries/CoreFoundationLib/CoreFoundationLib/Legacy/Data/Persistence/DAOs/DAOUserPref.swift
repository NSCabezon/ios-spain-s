public protocol DAOUserPref {

    func remove() -> Bool

    func set(userPrefs: UserPrefDict) -> Bool

    func get() -> UserPrefDict
}
