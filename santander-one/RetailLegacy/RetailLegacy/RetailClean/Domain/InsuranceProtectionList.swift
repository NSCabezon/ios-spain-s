import SANLegacyLibrary

class InsuranceProtectionList: GenericProductList<InsuranceProtection> {
    static func create(_ from: [InsuranceDTO]?) -> InsuranceProtectionList {
        let list = from?.compactMap { InsuranceProtection(dto: $0) } ?? []
        return self.init(list)
    }
}
