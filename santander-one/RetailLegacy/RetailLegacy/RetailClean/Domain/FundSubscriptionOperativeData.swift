import Foundation

class FundSubscriptionOperativeData: ProductSelection<Fund> {
    var fundDetail: FundDetail?
    var account: Account?
    var fundSubscriptionTransaction: FundSubscriptionTransaction?
    var fundSubscription: FundSubscription?
    var amount: Amount?
    var shares: Decimal?
    var fundSubscriptionConfirm: FundSubscriptionConfirm?
    
    init(fund: Fund?) {
        super.init(list: [], productSelected: fund, titleKey: "toolbar_title_foundSubscription", subTitleKey: "deeplink_label_selectOriginFound")
    }
    
    func updatePre(funds: [Fund]) {
        self.list = funds
    }
    
    func update(fundDetail: FundDetail, account: Account?) {
        self.fundDetail = fundDetail
        self.account = account
    }
}
