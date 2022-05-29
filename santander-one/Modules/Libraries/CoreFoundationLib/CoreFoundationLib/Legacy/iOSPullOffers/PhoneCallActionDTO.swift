import CoreDomain

public struct PhoneCallAction: OfferActionRepresentable {
    public let actionValue: String
    public let type = "phone_call"
    
    public func getDeserialized() -> String {
        return "<action_value><![CDATA[\(actionValue)]]></action_value>"
    }
}
