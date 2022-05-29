import CoreDomain

struct NotSupportedAction: OfferActionRepresentable {
    let actionValue: String
    //! String not used. Defined by meaningness
    let type = "no_action_supported"
    
    func getDeserialized() -> String {
        return "<action_value>\(actionValue)</action_value>"
    }
}
