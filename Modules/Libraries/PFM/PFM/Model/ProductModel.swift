import Foundation

public struct ProductModel {
    public var userId: String
    public var id: String
    public var type: String
    public var lastUpdate: Date
    public var revision: Int
    
    public init(userId: String, id: String, type: String, lastUpdate: Date, revision: Int) {
        self.userId = userId
        self.id = id
        self.type = type
        self.lastUpdate = lastUpdate
        self.revision = revision
    }

}
