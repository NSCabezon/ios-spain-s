import SQLite
import SANLegacyLibrary

public class DAOPersistedUserAvatarImpl: DAOPersistedUserAvatar {
    
    private var logTag: String {
        return String(describing: type(of: self))
    }
    
    private let  allColumns: [Expressible] = [
        PersistedUserAvatarContract.columnUserIdentifier,
        PersistedUserAvatarContract.columnUserAvatar]
    
    private static var database: Connection!
    
    public init(persistenceDatabaseHelper: PersistenceDatabaseHelper) {
        DAOPersistedUserAvatarImpl.database = persistenceDatabaseHelper.openWritable()
    }
   

    
    private func toSetterValues(userId: String, image: Data) -> [Setter] {
        RetailLogger.d(logTag, "set image for \(userId)")
        var values = [Setter]()
        values.append(PersistedUserAvatarContract.columnUserIdentifier <- userId)
        values.append(PersistedUserAvatarContract.columnUserAvatar <- image.base64EncodedString(options: .lineLength64Characters))
        return values
    }
}

public extension DAOPersistedUserAvatarImpl {
    func set(userId: String, image: Data) -> Bool {
        let values = toSetterValues(userId: userId, image: image)
        if let result = try? DAOPersistedUserAvatarImpl.database.run(PersistedUserAvatarContract.table.insert(or: .replace, values)) {
            return result > -1
        }
        return false
    }
    
     func get(userId: String) -> Data? {
        let query = PersistedUserAvatarContract.table.select(allColumns)
        if let result = try? DAOPersistedUserAvatarImpl.database.prepare(query).first(where: { (row: Row) -> Bool in
            return row[PersistedUserAvatarContract.columnUserIdentifier] == userId
        }) {
            let base64String = result[PersistedUserAvatarContract.columnUserAvatar]
            return Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
        }
        return nil
    }
}
