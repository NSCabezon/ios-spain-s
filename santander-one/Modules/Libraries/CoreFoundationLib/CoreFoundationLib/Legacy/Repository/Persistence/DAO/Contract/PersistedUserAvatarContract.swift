import SQLite

public struct PersistedUserAvatarContract {
    public static let tablePersistedUserAvatar = "table_persisted_user_avatar"
    public static let table = Table(tablePersistedUserAvatar)
    public static let columnUserIdentifier = SQLite.Expression<String>("user_identifier")
    public static let columnUserAvatar = SQLite.Expression<String>("user_avatar")
}
