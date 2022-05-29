import CoreDomain

public struct ExternalUrlAction: OfferActionRepresentable {
    public let actionValue: String
    public let type = "external_url"
    
    public func getDeserialized() -> String {
        return "<action_value><![CDATA[\(actionValue)]]></action_value>"
    }
}
