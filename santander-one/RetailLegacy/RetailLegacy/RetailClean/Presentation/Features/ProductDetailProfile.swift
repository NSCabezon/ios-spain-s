import Foundation

protocol ProductDetailProfile: TrackerScreenProtocol {
    var productTitle: LocalizedStylableText { get }
    func getInfo() -> [TableModelViewSection]
    func requestDetail(completion: @escaping ([TableModelViewSection]?) -> Void)
    func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection]
    func detailProduct(completion: @escaping (CarouselItem) -> Void)
    func setFirstElement(sections: [TableModelViewSection])
    func showEditCell(sections: [TableModelViewSection]) -> [TableModelViewSection]?
    func aliasSection(withNewAlias alias: String?)
    func genericProduct() -> GenericProductProtocol?
}

extension ProductDetailProfile {
    
    func genericProduct() -> GenericProductProtocol? {
        return nil
    }
    
    func aliasSection(withNewAlias alias: String?) {}
    
    func showEditCell(sections: [TableModelViewSection]) -> [TableModelViewSection]? {
        return nil
    }
    
    func setFirstElement(sections: [TableModelViewSection]) {
        let firstSection = sections.first
        let firstElement = firstSection?.items[0] as? ProductDetailInfoViewModel
        firstElement?.isFirst = true
    }
}

protocol GenericProductProtocol {}

extension Account: GenericProductProtocol {}
extension Loan: GenericProductProtocol {}
extension Pension: GenericProductProtocol {}
extension Fund: GenericProductProtocol {}
extension Deposit: GenericProductProtocol {}
extension Card: GenericProductProtocol {}
extension CardDetail: GenericProductProtocol {}
extension Liquidation: GenericProductProtocol {}
extension LiquidationDetailList: GenericProductProtocol {}
extension StockAccount: GenericProductProtocol {}
extension BillAndAccount: GenericProductProtocol {}
