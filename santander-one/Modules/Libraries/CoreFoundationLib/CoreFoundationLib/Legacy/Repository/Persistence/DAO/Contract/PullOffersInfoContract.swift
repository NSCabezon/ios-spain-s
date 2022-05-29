import SQLite

public struct PullOffersInfoContract {
    public static let tablePullOffers = "table_persisted_pull_offers"
    public static let table = Table(tablePullOffers)
    public static let columnIdentifier = SQLite.Expression<String>("identifier")
    public static let columnUserIdentifier = SQLite.Expression<String>("user_identifier")
    public static let columnExpired = SQLite.Expression<Bool>("expired")
    public static let columnIterations = SQLite.Expression<Int>("iterations")
}
