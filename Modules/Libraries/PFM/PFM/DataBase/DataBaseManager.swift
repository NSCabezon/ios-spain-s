import SQLCipher
import CoreFoundationLib
import SQLite
import Logger

enum DataBaseManagerError: Error {
    case noDatabase
}

public class DataBaseManager: NSObject {
    
    public static let shared: DataBaseManager = {
        return DataBaseManager()
    }()
    
    public var product: DAOProduct!
    public var transaction: DAOTransaction!
    public var userImage: DAOUserImage!
    var virtualDescription: DAODescription!
    
    private var dataBase: Connection?
    private let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]

    override init() {
        super.init()
        
        product = DAOProduct(dbm: self)
        transaction = DAOTransaction(dbm: self)
        userImage = DAOUserImage(dbm: self)
        virtualDescription = DAODescription(dbm: self)
        
        let dbPath = getPath(fileName: "san2.sqlite3")
        logTrace("[DBM] DB Path: \(dbPath)")
        
        if let firstError = tryToPrepareDB(dbPath: dbPath, deleteOld: false) {
            logError("[DBM] Cannot open database with current secret. The current file will be deleted. One more time... Error: \(firstError)")
            
            if let secondError = tryToPrepareDB(dbPath: dbPath, deleteOld: true) {
                logError("[DBM] New attemp fail: \(secondError)")
            }
        }
    }
    
    // Database connection Wrapper:
    func prepare(_ query: String, bindings: [Binding?]) throws -> Statement {
        guard let dataBase = dataBase else {
            throw DataBaseManagerError.noDatabase
        } 
        let statement = try dataBase.run(query, bindings)
        return statement
    }
    
    func prepare(_ query: QueryType) throws -> AnySequence<Row> {
        guard let dataBase = dataBase else {
            throw DataBaseManagerError.noDatabase
        }
        return try dataBase.prepare(query)
    }
    
    func scalar(_ statement: String, _ bindings: [Binding?]) throws -> Binding? {
        guard let dataBase = dataBase else {
            throw DataBaseManagerError.noDatabase
        }
        return try dataBase.scalar(statement, bindings)
    }
    
    func scalar<V: SQLite.Value>(_ query: Select<V>) throws -> V {
        guard let dataBase = dataBase else {
            throw DataBaseManagerError.noDatabase
        }
        return try dataBase.scalar(query)
    }
    
    func scalar(_ query: ScalarQuery<Int>) throws -> Int? {
        guard let dataBase = dataBase else {
            throw DataBaseManagerError.noDatabase
        }
        return try dataBase.scalar(query)
    }
    
    func run(_ statement: String) {
        guard let dataBase = dataBase else { return }
        do {
            try dataBase.run(statement)
        } catch let error {
            logError(error)
        }
    }
    
    func run(_ update: Update) {
        guard let dataBase = dataBase else { return }
        do {
            let result = try dataBase.run(update)
            if result == 0 {
                logWarning("[DBM] The following query produces no updates: \(update.asSQL())")
            }
        } catch let error {
            logError(error)
        }
    }
    
    func run(_ delete: Delete) {
        guard let dataBase = dataBase else { return }
        do {
            let result = try dataBase.run(delete)
            if result == 0 {
                logError("[DBM] The following query deletes nothing: \(delete.asSQL())")
            }
        } catch let error {
            logError(error)
        }
    }
    
    func run(_ insert: Insert) {
        guard let dataBase = dataBase else { return }
        do {
            let result = try dataBase.run(insert)
            if result == 0 {
                logError("[DBM] Error running insert query: \(insert.asSQL())")
            }
        } catch let error {
            logError(error)
        }
    }
    
    // MARK: - Private methods
    
    private func tryToPrepareDB(dbPath: String, deleteOld: Bool = false) -> NSError? {
        do {
            let fileManager = FileManager.default
            if deleteOld && fileManager.fileExists(atPath: dbPath) {
                try fileManager.removeItem(atPath: dbPath)
                fileManager.createFile(atPath: dbPath, contents: nil, attributes: nil)
            }
            try prepareDataBase(dbPath: dbPath, deleteOld: deleteOld)
        } catch let error {
            let nsError = error as NSError
            logDebug("[DBM] \(nsError)")
            return error as NSError
        }
        return nil
    }
    
    private func prepareDataBase(dbPath: String, deleteOld: Bool) throws {
        dataBase = try Connection(dbPath)
        guard let db = dataBase else { return }
        try enterKey(db)
        try db.run(product.createTable())
        try db.run(userImage.createTable())
        try db.run(transaction.createTable())
        try db.run(transaction.createIndex())
        try db.run(virtualDescription.createTable())
        do {
            try db.run(product.alterTableAddRevisionColumn())
        } catch let error {
            let nsError = error as NSError
            logDebug("[DBM] \(nsError)")
        }
    }
    
    private func getPath(fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        return fileURL.path
    }
    
    private func check(connection: Connection, _ resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        guard !successCodes.contains(resultCode) else { return resultCode }
        let message = String(cString: sqlite3_errmsg(connection.handle))
        throw Result.error(message: message, code: resultCode, statement: statement)
    }
    
    private func cipher_key_check(_ connection: Connection) throws {
        let _ = try connection.scalar("SELECT count(*) FROM sqlite_master;")
    }
    
    private func enterKey(_ connection: Connection) throws {
        let device = IOSDevice()
        let keyPointer = device.footprint
        let sqliteV2Manager = SqliteV2Manager()
        do {
            _ = try check(connection: connection,
                          sqliteV2Manager.sqlite3_key_v2_helper(connection.handle, zDb: "main", pKey: keyPointer, nKey: Int32(keyPointer.utf8.count)))
            try cipher_key_check(connection)
        } catch Result.error(_, SQLITE_NOTADB, _) {
            // We should migrate the database.
            _ = try check(connection: connection,
                          sqliteV2Manager.sqlite3_key_v2_helper(connection.handle, zDb: "main", pKey: keyPointer, nKey: Int32(keyPointer.utf8.count)))
            let migrateResult = try connection.scalar("PRAGMA cipher_migrate;")
            if (migrateResult as? String) != "0" {
                throw Result.error(message: "Error in cipher migration, result \(migrateResult.debugDescription)", code: 1, statement: nil)
            }
            try cipher_key_check(connection)
        }
    }
}
