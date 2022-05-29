import CoreDomain

public struct VideoAction: OfferActionRepresentable {
    public let actionValue: String
    public let type = "video"
    
    public func getDeserialized() -> String {
        return "<action_value>\(actionValue)</action_value>"
    }
}
