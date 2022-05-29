
public struct RecoveryPopupPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "pg_recobros_n3"
    
    public enum Action: String {
        case manageDebt = "gestionar_deuda"
    }
    public init() {}
}

public struct RecoveryCarrouselPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "pg_recobros_n2"
    
    public enum Action: String {
        case manageDebt = "gestionar_deuda"
    }
    public init() {}
}
