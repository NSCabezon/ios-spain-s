import SQLite

public struct PersistedUserContract {
    public static let tablePersistedUser = "table_persisted_user"
    public static let table = Table(tablePersistedUser)
    public static let columnUserLoginType = SQLite.Expression<String>("user_type_doc")
    public static let columnUserLogin = SQLite.Expression<String>("user_login")
    public static let columnUserEnvironmentName = SQLite.Expression<String>("user_environment_name")
    public static let columnUserName = SQLite.Expression<String?>("name")
    public static let columnUserPb = SQLite.Expression<String>("user_pb")
    public static let columnUserBdpCode = SQLite.Expression<String?>("bdp_code")
    public static let columnUserComCode = SQLite.Expression<String?>("com_code")
    public static let columnUserChannelFrame = SQLite.Expression<String?>("channel_frame")
    public static let columnUserTouchTokenCiphered = SQLite.Expression<String?>("touch_token_ciphered")
    public static let columnUserIsSmart = SQLite.Expression<String?>("user_smart")
    public static let columnUserId = SQLite.Expression<String?>("user_id")
    public static let columnIsEncrypted = SQLite.Expression<Bool>("is_encrypted")
    public static let columnBiometryData = SQLite.Expression<Data?>("biometry_data")
}
