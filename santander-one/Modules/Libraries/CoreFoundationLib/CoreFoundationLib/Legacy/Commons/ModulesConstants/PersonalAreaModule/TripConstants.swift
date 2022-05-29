
public struct TripPullOffer {
    public static let tripMode = "MODO_VIAJE_LISTADO"
}

public struct TripPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "modo_viaje"
    
    public enum Action: String {
        case add = "añadir"
        case newTravel = "nuevo_viaje"
    }
    public init() {}
}

public struct TripDetailPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "modo_viaje_detalle"
    
    public enum Action: String {
        case intelligentBlock = "bloqueo_inteligente"
        case robbery = "robo"
        case fraud = "fraude"
        case multichannelSignal = "firma_multicanal"
        case atm = "cajeros"
        case swipe
    }
    public init() {}
}
