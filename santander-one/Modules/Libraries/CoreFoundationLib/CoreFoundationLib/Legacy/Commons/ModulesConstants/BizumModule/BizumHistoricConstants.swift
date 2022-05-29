
public struct BizumHistoricPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_historico"
    public enum Action: String {
        case filter = "filtro"
        case search = "busqueda"
        case goToDetail = "ver_detalle"
    }
    
    public init() {}
}
