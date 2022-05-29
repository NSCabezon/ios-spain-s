public protocol InsurancePolicyRepresentable {
    var codCompanySeg: String? { get }
    var codRamo: String? { get }
    var productCod: String? { get }
    var policyNumber: String? { get }
    var policyCertNumber: String? { get }
    var description: String { get }
}
