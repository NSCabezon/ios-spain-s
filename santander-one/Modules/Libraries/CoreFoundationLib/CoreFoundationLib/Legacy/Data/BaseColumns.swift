import SQLite

class BaseColumns {
    static let _ID = SQLite.Expression<String>("_id")
    static let _COUNT = SQLite.Expression<String>("_count")
}
