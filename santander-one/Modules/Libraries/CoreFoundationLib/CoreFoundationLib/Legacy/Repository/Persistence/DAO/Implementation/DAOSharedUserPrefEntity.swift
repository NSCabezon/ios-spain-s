

public class DAOSharedUserPrefEntity: DAOSharedUserPrefEntityProtocol {
    private let dataRepository: DataRepository

    public init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }

    public func remove() -> Bool {
        dataRepository.remove(SharedUserPrefDictEntity.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func set(userPrefs: SharedUserPrefDictEntity) -> Bool {
        dataRepository.store(userPrefs, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func get() -> SharedUserPrefDictEntity {
        if let userPrefs = dataRepository.get(SharedUserPrefDictEntity.self, DataRepositoryPolicy.createPersistentPolicy()) {
            return userPrefs
        }
        return SharedUserPrefDictEntity()
    }
}

public protocol DAOSharedUserPrefEntityProtocol {
    func remove() -> Bool
    func set(userPrefs: SharedUserPrefDictEntity) -> Bool
    func get() -> SharedUserPrefDictEntity
}
