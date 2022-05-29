import CoreDomain

public struct RuleDTO {
    public let id: String
    public let expression: String
}

extension RuleDTO: RuleRepresentable {
    public var identifier: String {
        return id
    }
}
