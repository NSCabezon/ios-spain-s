import CoreDomain

public struct NavigateScreenAction: OfferActionRepresentable {
    public let actionValue: String
    //ID from offer.
    public let id: String?
    public let type = "navigate_screen"
    
    init(actionValue: String, id: String? = "") {
        self.actionValue = actionValue
        self.id = id
    }
    
    public func getDeserialized() -> String {
        var output = "<action_value>\(actionValue)</action_value>"
        if let id = id {
            output += "<id>\(id)</id>"
        }
        return output
    }
}
