import SQLite

public class DAOPullOffersInfoImpl {
    private let allColumns: [Expressible] = [
        PullOffersInfoContract.columnIdentifier,
        PullOffersInfoContract.columnUserIdentifier,
        PullOffersInfoContract.columnExpired,
        PullOffersInfoContract.columnIterations]
    
    private static var database: Connection!
    
    public init(persistenceDatabaseHelper: PersistenceDatabaseHelper) {
        DAOPullOffersInfoImpl.database = persistenceDatabaseHelper.openWritable()
    }
    
    private func toObject(_ row: Row) -> PullOffersInfoDTO {
        let offerId = row[PullOffersInfoContract.columnIdentifier]
        let userId = row[PullOffersInfoContract.columnUserIdentifier]
        let expired = row[PullOffersInfoContract.columnExpired]
        let iterations = row[PullOffersInfoContract.columnIterations]
        let pullOffersDTO = PullOffersInfoDTO(offerId: offerId, userId: userId, expired: expired, iterations: iterations)
        return pullOffersDTO
    }
    
    private func toSetterValues(_ pullOffersDTO: PullOffersInfoDTO) -> [Setter] {
        var values = [Setter]()
        values.append(PullOffersInfoContract.columnIdentifier <- pullOffersDTO.offerId)
        values.append(PullOffersInfoContract.columnUserIdentifier <- pullOffersDTO.userId)
        values.append(PullOffersInfoContract.columnExpired <- pullOffersDTO.expired)
        values.append(PullOffersInfoContract.columnIterations <- pullOffersDTO.iterations)
        return values
    }
}

public extension DAOPullOffersInfoImpl {
    func remove(userId: String, offerId: String) -> Bool {
        let userIdColumn = PullOffersInfoContract.columnUserIdentifier
        let offerIdColumn = PullOffersInfoContract.columnIdentifier
        let query = PullOffersInfoContract.table.select(allColumns).filter(userIdColumn == userId).filter(offerIdColumn == offerId)
        if let result = try? DAOPullOffersInfoImpl.database.run(query.delete()) {
            return result > -1
        }
        return false
    }
    
    func set(pullOffersInfo: PullOffersInfoDTO) -> Bool {
        let values = toSetterValues(pullOffersInfo)
        if let result = try? DAOPullOffersInfoImpl.database.run(PullOffersInfoContract.table.insert(or: .replace, values)) {
            return result > -1
        }
        return false
    }
    
    func get(userId: String, offerId: String) -> PullOffersInfoDTO? {
        let userIdColumn = PullOffersInfoContract.columnUserIdentifier
        let offerIdColumn = PullOffersInfoContract.columnIdentifier
        let query = PullOffersInfoContract.table.select(allColumns).filter(userIdColumn == userId).filter(offerIdColumn == offerId)
        var pullOffersDTO: PullOffersInfoDTO?
        if let result = try? DAOPullOffersInfoImpl.database.prepare(query) {
            let rows = result.makeIterator()
            if let row = rows.next() {
                pullOffersDTO = toObject(row)
            }
        }
        return pullOffersDTO
    }
}

extension DAOPullOffersInfoImpl: DAOPullOffersInfo {}
