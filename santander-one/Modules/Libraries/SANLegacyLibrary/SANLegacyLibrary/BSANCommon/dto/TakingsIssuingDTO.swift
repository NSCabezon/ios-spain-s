public struct TakingsIssuingDTO: Codable {
    public var issuing: String?
    public var product: String?
    public var takingsSubType: TakingsSubTypeDTO?
    
    public init() {}
}
