

public class DAOSharedPersistedUser: DAOSharedPersistedUserProtocol {
    
    private let dataRepository: DataRepository
    
    public init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }
    
    public func remove() -> Bool {
        dataRepository.remove(SharedPersistedUserDTO.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func set(persistedUser: SharedPersistedUserDTO) -> Bool {
        dataRepository.store(persistedUser, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    
    public func get() -> SharedPersistedUserDTO? {
        return dataRepository.get(SharedPersistedUserDTO.self, DataRepositoryPolicy.createPersistentPolicy())
    }
}
