
public struct ComingFeaturesPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "zona_proximamente"
    
    public enum Action: String {
        case vote = "votar_idea"
        case tryNews = "probar_novedades"
        case addIdea = "añadir_idea"
    }
    public init() {}
}
