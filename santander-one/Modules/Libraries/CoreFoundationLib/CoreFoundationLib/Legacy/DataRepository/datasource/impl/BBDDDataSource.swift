import SQLite

public class BBDDDataSource {
    private var serializer: Serializer
    private let dataCipher: DataCipher
    private let userDefaults: UserDefaults
    private var connection: Connection?
    private let databaseName: String = "bsan_data_ciphered.sqlite3"
    private let primaryKey = " PRIMARY KEY"
    private let textType = " TEXT"
    private let notNullType = " NOT NULL"
    private let tableName = "table_persisted"
    private let commaSep = ","
    private lazy var table = { Table(self.tableName) }()
    private let columnIdentifier = SQLite.Expression<String>("identifier")
    private let columnData = SQLite.Expression<String>("data")
    private lazy var sqlCreateTable = {
        "CREATE TABLE IF NOT EXISTS \(self.tableName) ("
            + "\(self.columnIdentifier.asSQL()) \(self.textType) \(self.notNullType) \(self.commaSep)"
            + "\(self.columnData.asSQL()) \(self.textType) \(self.notNullType) \(self.commaSep)"
            + "\(self.primaryKey) (\(self.columnIdentifier.asSQL())));"
    }()
    private lazy var allColumns: [Expressible] = { [self.columnIdentifier, self.columnData] }()

    public init(serializer: Serializer, keychainService: KeychainService, appInfo: VersionInfoDTO) {
        self.serializer = serializer
        self.dataCipher = DataCipher(keychainService: keychainService)
        self.userDefaults = UserDefaults.standard
        self.openDDBB()
    }
}

// MARK: - DataSource

extension BBDDDataSource: DataSource {
    public func getType() -> Int {
        return StoragePolicyType.PERSISTENT_STORAGE
    }
    
    public func store<T>(dataWrapper: DataWrapper<T>) where T : Decodable, T : Encodable {
        let serialized = self.serializer.serialize(dataWrapper)
        let key = dataWrapper.getkey()
        self.putBBDD(key, plainText: serialized)
        self.removeUD(key)
    }
    
    public func get<T>(key: String, type: T.Type) -> DataWrapper<T>? where T : Decodable, T : Encodable {
        if let serialized = self.getBBDD(key), !serialized.isEmpty {
            return self.serializer.deserializeWrapper(serialized, type)
        } else {
            return self.migrateFromUD(key: key, type: type)
        }
    }
    
    public func remove(key: String) {
        self.removeUD(key)
        self.removeBBDD(key)
    }
    
    public func clear() {
    }
}

// MARK: - Private

private extension BBDDDataSource {
 
    func removeBBDD(_ key: String) {
        let query = self.table.filter(self.columnIdentifier == key)
        let _ = try? self.connection?.run(query.delete())
    }
    
    func putBBDD(_ key: String, plainText: String?) {
        if let plainText = plainText {
            let cipherText = self.dataCipher.encryptAES(plainText)
            let values = self.toSetterValues(key: key, data: cipherText)
            let _ = try? self.connection?.run(self.table.insert(or: .replace, values))
        } else {
            self.removeBBDD(key)
        }
    }

    func getBBDD(_ key: String) -> String? {
        let query = self.table.select(self.allColumns)
        if let result = try? self.connection?.prepare(query).first(where: { (row: Row) -> Bool in
            return row[self.columnIdentifier] == key
        }) {
            let cipheredText = result[self.columnData]
            let decipheredText  = self.dataCipher.decryptAES(cipheredText)
            return decipheredText
        } else {
            return nil
        }
    }
    
    func removeUD(_ key: String) {
        self.userDefaults.set(nil, forKey: key)
    }
    
    func getUD(_ key: String) -> String? {
        if let cipheredText = self.userDefaults.string(forKey: key) {
            let decipheredText  = self.dataCipher.decryptAES(cipheredText)
            return decipheredText
        } else {
            return nil
        }
    }
    
    func migrateFromUD<T>(key: String, type: T.Type) -> DataWrapper<T>? where T : Decodable, T : Encodable {
        guard let serialized = self.getUD(key), !serialized.isEmpty  else {
            return nil
        }
        self.putBBDD(key, plainText: serialized)
        self.removeUD(key)
        return self.serializer.deserializeWrapper(serialized, type)
    }
    
    func openDDBB() {
        guard let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first else {
            return
        }
        let dbPath = "\(path)/\(self.databaseName)"
        self.connection = try? Connection(dbPath, readonly: false)
        try? self.connection?.execute(self.sqlCreateTable)
    }
    
    func toSetterValues(key: String, data: String) -> [Setter] {
        var values = [Setter]()
        values.append(self.columnIdentifier <- key)
        values.append(self.columnData <- data)
        return values
    }
}
