
public class DAOUserPrefImpl: DAOUserPref {

    private let dataRepository: DataRepository
    private let secondarySaverDataRepository: DataRepository?

    public init(dataRepository: DataRepository, secondarySaverDataRepository: DataRepository?) {
        self.dataRepository = dataRepository
        self.secondarySaverDataRepository = secondarySaverDataRepository
    }

    public func remove() -> Bool {
        dataRepository.remove(UserPrefDict.self, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.remove(UserPrefDict.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func set(userPrefs: UserPrefDict) -> Bool {
        dataRepository.store(userPrefs, DataRepositoryPolicy.createPersistentPolicy())
        secondarySaverDataRepository?.store(userPrefs, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }

    public func get() -> UserPrefDict {
        if let userPrefs = dataRepository.get(UserPrefDict.self, DataRepositoryPolicy.createPersistentPolicy()) {
            return userPrefs
        }
        return UserPrefDict()
    }
}
