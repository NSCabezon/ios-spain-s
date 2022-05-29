import CoreDomain

public struct OfferLinkAction: OfferActionRepresentable {
    public let actionValue: String
    public let type = "offer_link"
    
    public func getDeserialized() -> String {
        return "<action_value><![CDATA[\(actionValue)]]></action_value>"
    }
}
