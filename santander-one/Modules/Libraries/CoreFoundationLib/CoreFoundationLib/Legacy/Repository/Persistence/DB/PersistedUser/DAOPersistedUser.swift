import SQLite
import SANLegacyLibrary


public class DAOPersistedUser: DAOPersistedUserProtocol {
    private var logTag: String {
        return String(describing: type(of: self))
    }
    private var serializer: Serializer
    private let dataCipher: DataCipher
    
    private let allColumns: [Expressible] = [
        PersistedUserContract.columnUserLogin,
        PersistedUserContract.columnUserName,
        PersistedUserContract.columnUserLoginType,
        PersistedUserContract.columnUserEnvironmentName,
        PersistedUserContract.columnUserPb,
        PersistedUserContract.columnUserBdpCode,
        PersistedUserContract.columnUserComCode,
        PersistedUserContract.columnUserChannelFrame,
        PersistedUserContract.columnUserTouchTokenCiphered,
        PersistedUserContract.columnUserIsSmart,
        PersistedUserContract.columnUserId,
        PersistedUserContract.columnBiometryData,
        PersistedUserContract.columnIsEncrypted]
    
    private static var database: Connection!
    
    public init(persistenceDatabaseHelper: PersistenceDatabaseHelper, keychainService: KeychainService, serializer: Serializer ) {
        DAOPersistedUser.database = persistenceDatabaseHelper.openWritable()
        self.serializer = serializer
        self.dataCipher = DataCipher(keychainService: keychainService)
    }
    
    public func remove() -> Bool {
        RetailLogger.d(logTag, "remove persistedUser")
        if let result = try? DAOPersistedUser.database.run(PersistedUserContract.table.delete()) {
            return result > -1
        }
        return false
    }
    
    public func set(persistedUser: PersistedUserDTO) -> Bool {
        let values = toSetterValues(persistedUser)
        return isPersistedUser(persistedUser: persistedUser) ? update(values) : create(values)
    }
    
    public func isPersistedUser(persistedUser: PersistedUserDTO) -> Bool {
        let query = PersistedUserContract.table.filter(PersistedUserContract.columnUserLogin == persistedUser.login)
        if let result = try? DAOPersistedUser.database.prepare(query) {
            let rows = result.makeIterator()
            if let row = rows.next() {
                return (persistedUser.login == row[PersistedUserContract.columnUserLogin])
            }
        }
        return false
    }
    
    public func get() -> PersistedUserDTO? {
        let query = PersistedUserContract.table.select(allColumns)
        var persistedUser: PersistedUserDTO?
        if let result = try? DAOPersistedUser.database.prepare(query) {
            let rows = result.makeIterator()
            if let row = rows.next() {
                if !row[PersistedUserContract.columnIsEncrypted] {
                    guard let retrievedUser = toObject(row, isRowEncrypted: false) else {
                        return nil
                    }
                    _ = set(persistedUser: retrievedUser)
                    persistedUser = toObject(row, isRowEncrypted: false)
                } else {
                    persistedUser = toObject(row, isRowEncrypted: true)
                }
            }
        }
        return persistedUser
    }
    
    private func toObject(_ row: Row, isRowEncrypted: Bool) -> PersistedUserDTO? {
        var persistedUser: PersistedUserDTO
        
        let loginType = dataCipher.decryptNotNull(row[PersistedUserContract.columnUserLoginType], isEncrypted: isRowEncrypted)
        let login = dataCipher.decryptNotNull(row[PersistedUserContract.columnUserLogin], isEncrypted: isRowEncrypted)
        let environmentName = dataCipher.decryptNotNull(row[PersistedUserContract.columnUserEnvironmentName], isEncrypted: isRowEncrypted)
        let name = dataCipher.decryptNull(row[PersistedUserContract.columnUserName], isEncrypted: isRowEncrypted)
        let pbUser = row[PersistedUserContract.columnUserPb] == "1"
        let bdpCode = dataCipher.decryptNull(row[PersistedUserContract.columnUserBdpCode], isEncrypted: isRowEncrypted)
        let comCode = dataCipher.decryptNull(row[PersistedUserContract.columnUserComCode], isEncrypted: isRowEncrypted)
        let channelFrame = dataCipher.decryptNull(row[PersistedUserContract.columnUserChannelFrame], isEncrypted: isRowEncrypted)
        let touchTokenCiphered = dataCipher.decryptNull(row[PersistedUserContract.columnUserTouchTokenCiphered], isEncrypted: isRowEncrypted)
        let isSmart = row[PersistedUserContract.columnUserIsSmart] == "1"
        let userId = dataCipher.decryptNull(row[PersistedUserContract.columnUserId], isEncrypted: isRowEncrypted)
        let biometryData = row[PersistedUserContract.columnBiometryData]
        guard let userLoginType = UserLoginType(loginType),
              environmentName.count > 0,
              login.count > 0
        else {
            return nil
        }
        persistedUser = PersistedUserDTO.createPersistedUser(touchTokenCiphered: touchTokenCiphered,
                                                             loginType: userLoginType,
                                                             login: login,
                                                             environmentName: environmentName,
                                                             channelFrame: channelFrame,
                                                             isPb: pbUser,
                                                             name: name,
                                                             bdpCode: bdpCode,
                                                             comCode: comCode,
                                                             isSmart: isSmart,
                                                             userId: userId,
                                                             biometryData: biometryData)
        RetailLogger.d(logTag, "get \(persistedUser.description)")
        return persistedUser
    }
    
    private func toSetterValues(_ persistedUser: PersistedUserDTO) -> [Setter] {
        RetailLogger.d(logTag, "set \(persistedUser.description)")
        var values = [Setter]()
        
        values.append(PersistedUserContract.columnUserLogin <- dataCipher.encryptAES(persistedUser.login))
        values.append(PersistedUserContract.columnUserLoginType <- dataCipher.encryptAES(persistedUser.loginType.rawValue))
        values.append(PersistedUserContract.columnUserEnvironmentName <- dataCipher.encryptAES(persistedUser.environmentName))
        values.append(PersistedUserContract.columnUserPb <-  persistedUser.isPb ? "1":"0")
        values.append(PersistedUserContract.columnUserName <- dataCipher.encryptNull(persistedUser.name))
        values.append(PersistedUserContract.columnUserBdpCode <- dataCipher.encryptNull(persistedUser.bdpCode))
        values.append(PersistedUserContract.columnUserComCode <- dataCipher.encryptNull( persistedUser.comCode))
        values.append(PersistedUserContract.columnUserChannelFrame <- dataCipher.encryptNull(persistedUser.channelFrame))
        values.append(PersistedUserContract.columnUserTouchTokenCiphered <- dataCipher.encryptNull(persistedUser.touchTokenCiphered))
        values.append(PersistedUserContract.columnUserIsSmart <- persistedUser.isSmart ? "1":"0")
        values.append(PersistedUserContract.columnUserId <- dataCipher.encryptNull( persistedUser.userId))
        values.append(PersistedUserContract.columnBiometryData <-  persistedUser.biometryData)
        values.append(PersistedUserContract.columnIsEncrypted <- true)
        return values
    }
}

private extension DAOPersistedUser {
    func update(_ values: [Setter]) -> Bool {
        guard let result = try? DAOPersistedUser.database.run(PersistedUserContract.table.update(values)) else { return false }
        return result > -1
    }
    
    func create(_ values: [Setter]) -> Bool {
        guard let result = try? DAOPersistedUser.database.run(PersistedUserContract.table.insert(or: .replace, values)) else { return false }
        return result > -1
    }
}
