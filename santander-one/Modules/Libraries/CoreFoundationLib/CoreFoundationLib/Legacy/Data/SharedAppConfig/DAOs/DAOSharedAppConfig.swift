public protocol DAOSharedAppConfig {
    func remove() -> Bool
    func set(sharedAppConfig: SharedAppConfig) -> Bool
    func get() -> SharedAppConfig
}
