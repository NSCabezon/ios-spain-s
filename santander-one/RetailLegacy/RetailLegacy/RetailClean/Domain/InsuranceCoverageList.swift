import SANLegacyLibrary

class InsuranceCoverageList: GenericProductList<InsuranceCoverage> {
    static func create(_ from: [InsuranceCoverageDTO]?) -> InsuranceCoverageList {
        let list = from?.compactMap { InsuranceCoverage.create($0) } ?? []
        return self.init(list)
    }
}
