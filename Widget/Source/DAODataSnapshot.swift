import CoreFoundationLib

protocol DAODataSnapshot {
    func remove() -> Bool
    func set(dataSnapshot: DataSnapshot) -> Bool
    func get() -> DataSnapshot?
}

class DAODataSnapshotImpl {
    private let dataRepository: DataRepository
    
    init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
    }
}

extension DAODataSnapshotImpl: DAODataSnapshot {
    func remove() -> Bool {
        dataRepository.remove(DataSnapshot.self, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    func set(dataSnapshot: DataSnapshot) -> Bool {
        dataRepository.store(dataSnapshot, DataRepositoryPolicy.createPersistentPolicy())
        return true
    }
    func get() -> DataSnapshot? {
        return dataRepository.get(DataSnapshot.self, DataRepositoryPolicy.createPersistentPolicy())
    }
}
