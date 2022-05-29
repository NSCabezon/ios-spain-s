public struct ProductOneRangeDTO {
    public let type: Int
    public let subtypeFrom: Int
    public let subtypeTo: Int
    
    public init(type: Int, subtypeFrom: Int, subtypeTo: Int) {
        self.type = type
        self.subtypeFrom = subtypeFrom
        self.subtypeTo = subtypeTo
    }
    
    public var identifier: String {
        "\(type)\(subtypeFrom)\(subtypeTo)"
    }
}
