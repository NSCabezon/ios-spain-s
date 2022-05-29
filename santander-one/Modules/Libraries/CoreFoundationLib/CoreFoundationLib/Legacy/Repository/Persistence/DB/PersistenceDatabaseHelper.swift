import SQLite
import SANLegacyLibrary


public class PersistenceDatabaseHelper: SQLiteOpenHelper {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    private static var connection: Connection?
    private let databaseName: String = "bsan_ciphered.sqlite3"
    private let databaseVersion: Int = 8
    
    private static let primaryKey = " PRIMARY KEY"
    private static let textType = " TEXT"
    private static let integerType = " INTEGER"
    private static let boolType = " BOOL"
    private static let notNullType = " NOT NULL"
    private static let commaSep = ","
    
    public static let sqlCreateTablePersistedUser = "CREATE TABLE IF NOT EXISTS \(PersistedUserContract.tablePersistedUser) ("
        + "\(PersistedUserContract.columnUserLogin.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PersistedUserContract.columnUserLoginType.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PersistedUserContract.columnUserEnvironmentName.asSQL()) \(textType)  \(notNullType) \(commaSep)"
        + "\(PersistedUserContract.columnUserName.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnUserPb.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PersistedUserContract.columnUserBdpCode.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnUserComCode.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnUserChannelFrame.asSQL()) \(textType)  \(commaSep)"
        + "\(PersistedUserContract.columnUserTouchTokenCiphered.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnUserIsSmart.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnUserId.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnBiometryData.asSQL()) \(textType) \(commaSep)"
        + "\(PersistedUserContract.columnIsEncrypted.asSQL()) \(boolType) \(notNullType) \(commaSep)"
        + "\(primaryKey) (\(PersistedUserContract.columnUserLogin.asSQL())));"
    
    public static let sqlCreateTablePersistedUserAvatar = "CREATE TABLE IF NOT EXISTS \(PersistedUserAvatarContract.tablePersistedUserAvatar) ("
        + "\(PersistedUserAvatarContract.columnUserIdentifier.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PersistedUserAvatarContract.columnUserAvatar.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(primaryKey) (\(PersistedUserAvatarContract.columnUserIdentifier.asSQL())));"
    
    public static let sqlCreateTablePersistedPullOffer = "CREATE TABLE IF NOT EXISTS \(PullOffersInfoContract.tablePullOffers) ("
        + "\(PullOffersInfoContract.columnIdentifier.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PullOffersInfoContract.columnUserIdentifier.asSQL()) \(textType) \(notNullType) \(commaSep)"
        + "\(PullOffersInfoContract.columnExpired.asSQL()) \(boolType) \(notNullType) \(commaSep)"
        + "\(PullOffersInfoContract.columnIterations.asSQL()) \(integerType) \(notNullType) \(commaSep)"
        + "\(primaryKey) (\(PullOffersInfoContract.columnIdentifier.asSQL()) \(commaSep) \(PullOffersInfoContract.columnUserIdentifier.asSQL()))"
        + ");"
    
    public init() {
        super.init(name: databaseName, version: databaseVersion)
        _ = self.openWritable()
    }
    
    override public func onCreate(_ database: Connection) {
        RetailLogger.d(logTag, "onCreate")
        createAllTables(database)
    }
    
    private func addField(sFieldName: String, sTable: String, sType: String, sDefaultValue: String?, database: Connection) {
        var sSQL = "ALTER TABLE " + sTable + " ADD COLUMN " + sFieldName + sType
        if let sDefaultValue = sDefaultValue, !sDefaultValue.isEmpty {
            sSQL += " DEFAULT " + sDefaultValue
        }
        RetailLogger.d(logTag, "Update table \(sTable) with colum \(sFieldName)...")
        try? database.execute(sSQL)
    }

    private func createAllTables(_ database: Connection) {
        RetailLogger.d(logTag, "Creating all tables...")
        RetailLogger.v(logTag, PersistenceDatabaseHelper.sqlCreateTablePersistedUser)
        try? database.execute(PersistenceDatabaseHelper.sqlCreateTablePersistedUser)
        RetailLogger.v(logTag, PersistenceDatabaseHelper.sqlCreateTablePersistedUserAvatar)
        try? database.execute(PersistenceDatabaseHelper.sqlCreateTablePersistedUserAvatar)
        RetailLogger.v(logTag, PersistenceDatabaseHelper.sqlCreateTablePersistedPullOffer)
        try? database.execute(PersistenceDatabaseHelper.sqlCreateTablePersistedPullOffer)
        RetailLogger.d(logTag, "All tables created!")
    }
    
    private func deleteAllTables(_ database: Connection) {
        RetailLogger.d(logTag, "Deleting all tables...")
        try? database.execute("DROP TABLE IF EXISTS \(PersistedUserContract.tablePersistedUser)")
        try? database.execute("DROP TABLE IF EXISTS \(PersistedUserAvatarContract.tablePersistedUserAvatar)")
        RetailLogger.d(logTag, "All tables deleted!")
    }
    
    override public func onUpgrade(_ database: Connection, _ oldVersion: Int, _ newVersion: Int) {
        RetailLogger.d(logTag, "Database - onUpgrade - oldVersion: \(oldVersion), newVersion: \(newVersion)")
        if newVersion < oldVersion {
            deleteAllTables(database)
            createAllTables(database)
        } else if newVersion != oldVersion {
            switch oldVersion {
            case 1:
                addAvatarTable(database)
                fallthrough
            case 2:
                addPullOffersTable(database)
                fallthrough
            case 3:
                addSmartFieldToPersistedUser(database)
                fallthrough
            case 4:
                addAvatarTable(database)
                fallthrough
            case 5:
                addUserIdFieldToPersistedUser(database)
                fallthrough
            case 6:
                addBiometryFieldToPersistedUser(database)
                fallthrough
            case 7:
                addEncryptedFieldToPersistedUser(database)
            default:
                deleteAllTables(database)
                createAllTables(database)
            }
        }
    }
    
    private func addAvatarTable(_ database: Connection) {
        RetailLogger.v(logTag, PersistenceDatabaseHelper.sqlCreateTablePersistedUserAvatar)
        try? database.execute(PersistenceDatabaseHelper.sqlCreateTablePersistedUserAvatar)
    }
    
    private func addPullOffersTable(_ database: Connection) {
        RetailLogger.v(logTag, PersistenceDatabaseHelper.sqlCreateTablePersistedPullOffer)
        try? database.execute(PersistenceDatabaseHelper.sqlCreateTablePersistedPullOffer)
    }
    
    private func addSmartFieldToPersistedUser(_ database: Connection) {
        addField(sFieldName: PersistedUserContract.columnUserIsSmart.asSQL(),
                 sTable: PersistedUserContract.tablePersistedUser,
                 sType: PersistenceDatabaseHelper.textType,
                 sDefaultValue: nil,
                 database: database)
    }
    
    private func addUserIdFieldToPersistedUser(_ database: Connection) {
        addField(sFieldName: PersistedUserContract.columnUserId.asSQL(),
                 sTable: PersistedUserContract.tablePersistedUser,
                 sType: PersistenceDatabaseHelper.textType,
                 sDefaultValue: nil,
                 database: database)
    }
    
    private func addBiometryFieldToPersistedUser(_ database: Connection) {
        addField(sFieldName: PersistedUserContract.columnBiometryData.asSQL(),
                 sTable: PersistedUserContract.tablePersistedUser,
                 sType: PersistenceDatabaseHelper.textType,
                 sDefaultValue: nil,
                 database: database)
    }
    
    private func addEncryptedFieldToPersistedUser(_ database: Connection) {
        addField(sFieldName: PersistedUserContract.columnIsEncrypted.asSQL(),
                 sTable: PersistedUserContract.tablePersistedUser,
                 sType: PersistenceDatabaseHelper.boolType,
                 sDefaultValue: "false",
                 database: database)
    }
    
    public func openWritable() -> Connection {
        if let connection = PersistenceDatabaseHelper.connection {
            return connection
        }
        let connection = open()
        PersistenceDatabaseHelper.connection = connection
        return connection
    }
}
