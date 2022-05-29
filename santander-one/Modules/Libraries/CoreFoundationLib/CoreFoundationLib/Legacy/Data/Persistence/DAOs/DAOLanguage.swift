
public protocol DAOLanguage {
    func remove() -> Bool
    func set(language: LanguageType) -> Bool
    func get() -> LanguageType?
}
