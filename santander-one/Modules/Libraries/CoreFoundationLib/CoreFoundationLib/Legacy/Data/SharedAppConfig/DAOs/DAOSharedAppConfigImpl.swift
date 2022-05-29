
public class DAOSharedAppConfigImpl: DAOSharedAppConfig {
    
    private let dataRepository: DataRepository
    
    public init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }
    
    public func remove() -> Bool {
        dataRepository.remove(SharedAppConfig.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func set(sharedAppConfig: SharedAppConfig) -> Bool {
        dataRepository.store(sharedAppConfig, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func get() -> SharedAppConfig {
        return dataRepository.get(SharedAppConfig.self, DataRepositoryPolicy.createPersistentPolicy()) ?? SharedAppConfig()
    }
}
