
public class DAOLanguageImpl: DAOLanguage {
    
    private let dataRepository: DataRepository
    private let secondarySaverDataRepository: DataRepository?
    
    public init(dataRepository: DataRepository, secondarySaverDataRepository: DataRepository?) {
        self.dataRepository = dataRepository
        self.secondarySaverDataRepository = secondarySaverDataRepository
    }
    
    public func remove() -> Bool {
        dataRepository.remove(LanguageType.self, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.remove(LanguageType.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func set(language: LanguageType) -> Bool {
        dataRepository.store(language, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.store(language, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func get() -> LanguageType? {
        guard let language = dataRepository.get(LanguageType.self, DataRepositoryPolicy.createPersistentPolicy()) else {
            return nil
        }
        return language
    }
}
