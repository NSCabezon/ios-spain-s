import SANLegacyLibrary

class PortfolioList: GenericProductList<Portfolio> {
    static func create(_ from: [PortfolioDTO]?) -> PortfolioList {
        let list = from?.compactMap { Portfolio(dto: $0) } ?? []
        return self.init(list)
    }
}
