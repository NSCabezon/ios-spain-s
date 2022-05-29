import CoreDomain

public struct InsurancePolicyDTO: Codable, CustomStringConvertible {
    public var codCompanySeg: String?
    public var codRamo: String?
    public var productCod: String?
    public var policyNumber: String?
    public var policyCertNumber: String?
    
    public var description: String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 2
        var description: String = formatter.string(from: NSNumber(integerLiteral: Int(codCompanySeg ?? "0") ?? 0)) ?? ""
        description += formatter.string(from: NSNumber(integerLiteral: Int(codRamo ?? "0") ?? 0)) ?? ""
        description += formatter.string(from: NSNumber(integerLiteral: Int(productCod ?? "0") ?? 0)) ?? ""
        formatter.minimumIntegerDigits = 8
        formatter.maximumIntegerDigits = 8
        description += formatter.string(from: NSNumber(integerLiteral: Int(policyNumber ?? "0") ?? 0)) ?? ""
        formatter.minimumIntegerDigits = 6
        formatter.maximumIntegerDigits = 6
        description += formatter.string(from: NSNumber(integerLiteral: Int(policyCertNumber ?? "0") ?? 0)) ?? ""
        return description
    }

    public init () {}
}

extension InsurancePolicyDTO: InsurancePolicyRepresentable { }
