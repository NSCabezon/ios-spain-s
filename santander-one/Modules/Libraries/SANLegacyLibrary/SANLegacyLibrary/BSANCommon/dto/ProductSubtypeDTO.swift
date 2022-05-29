import CoreDomain

public struct ProductSubtypeDTO: Codable {
    
    public var company: String?
    public var productSubtype: String?
    public var productType: String?
    
    public init(company: String? = nil, productSubtype: String? = nil, productType: String? = nil) {
        self.company = company
        self.productSubtype = productSubtype
        self.productType = productType
    }
}

extension ProductSubtypeDTO: ProductSubtypeRepresentable { }
