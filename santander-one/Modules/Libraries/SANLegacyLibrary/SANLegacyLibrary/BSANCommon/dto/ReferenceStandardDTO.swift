public struct ReferenceStandardDTO: Codable {
    public var productSubtypeDTO: ProductSubtypeDTO?
    public var standardCode: String?
    
    public init() {}
    public init(productSubtypeDTO: ProductSubtypeDTO?, standardCode: String?) {
        self.productSubtypeDTO = productSubtypeDTO
        self.standardCode = standardCode
    }
}
