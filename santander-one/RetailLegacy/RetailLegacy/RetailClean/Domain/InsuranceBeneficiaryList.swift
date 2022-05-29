import SANLegacyLibrary

class InsuranceBeneficiaryList: GenericProductList<InsuranceBeneficiary> {
    static func create(_ from: [InsuranceBeneficiaryDTO]?) -> InsuranceBeneficiaryList {
        let list = from?.compactMap { InsuranceBeneficiary.create($0) } ?? []
        return self.init(list)
    }
}
