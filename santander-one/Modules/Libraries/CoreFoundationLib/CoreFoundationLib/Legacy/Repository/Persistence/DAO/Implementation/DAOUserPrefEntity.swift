

public class DAOUserPrefEntity: DAOUserPrefEntityProtocol {
    private let dataRepository: DataRepository
    private let secondarySaverDataRepository: DataRepository?

    public init(dataRepository: DataRepository, secondarySaverDataRepository: DataRepository?) {
        self.dataRepository = dataRepository
        self.secondarySaverDataRepository = secondarySaverDataRepository
    }

    public func remove() -> Bool {
        dataRepository.remove(UserPrefDictEntity.self, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.remove(UserPrefDictEntity.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func set(userPrefs: UserPrefDictEntity) -> Bool {
        dataRepository.store(userPrefs, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.store(userPrefs, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func get() -> UserPrefDictEntity {
        if let userPrefs = dataRepository.get(UserPrefDictEntity.self, DataRepositoryPolicy.createPersistentPolicy()) {
            return userPrefs
        }
        return UserPrefDictEntity()
    }
}
