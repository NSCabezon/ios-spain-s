import Foundation

public struct HomeTipsPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "consejos"
    
    public enum Action: String {
        case tipAccess = "acceder_consejo"
        case tipSeeAll = "consejos_ver_todos"
    }
    public init() {}
}

public struct TipListPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page: String = "consejos_listado"
    public enum Action: String {
        case selected = "acceder_consejo"
    }

    public init() {}
}
