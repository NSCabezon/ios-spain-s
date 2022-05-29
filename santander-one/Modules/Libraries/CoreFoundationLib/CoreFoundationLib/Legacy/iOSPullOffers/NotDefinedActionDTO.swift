import CoreDomain

struct NotDefinedActionDTO: OfferActionRepresentable {
    let actionValue: String
    //! String not used. Defined by meaningness
    let type = "no_action_defined"
    
    func getDeserialized() -> String {
        return "<action_value>\(actionValue)</action_value>"
    }
}
