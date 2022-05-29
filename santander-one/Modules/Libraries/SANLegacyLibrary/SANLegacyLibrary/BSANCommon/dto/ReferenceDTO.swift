import CoreDomain

public struct ReferenceDTO: Codable {
    public var reference: String?
    
    public init() {}

    public func getReferencePart1() -> String {
        return reference?.substring(0, 4) ?? ""
    }
    
    public func getReferencePart2() -> String {
        return reference?.substring(4, 8) ?? ""
    }
    
    public func getReferencePart3() -> String {
        return reference?.substring(8, 11) ?? ""
    }
    
    public func getReferencePart4() -> String {
        return reference?.substring(11) ?? ""
    }
}

extension ReferenceDTO: ReferenceRepresentable {}
