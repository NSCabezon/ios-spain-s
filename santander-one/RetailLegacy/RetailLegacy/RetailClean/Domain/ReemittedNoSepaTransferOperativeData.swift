import Foundation
import CoreFoundationLib

class ReemittedNoSepaTransferOperativeData: ProductSelection<Account> {
    var date: Date?
    let transferDetail: BaseNoSepaPayeeDetailProtocol
    var isDestinationSepaAccount: Bool?
    var swiftValidation: SwiftValidation?
    var transferType: NoSepaTransferType?
    var noSepaTransferValidation: NoSepaTransferValidation?
    var amount: Amount?
    var beneficiaryAccount: InternationalAccount?
    var transferExpenses: NoSepaTransferExpenses?
    var concept: String?
    var summaryState: OnePayTransferSummaryState?
    var sepaInfoList: SepaInfoList?
    var beneficiaryEmail: String?
    var operativeOrigin: ReemitedNoSepaTransferOrigin
    var payer: String?
    var faqs: [FaqsEntity]?
    let accountType: String?

    var selectedCountry: SepaCountryInfo? {
        return sepaInfoList?.getSepaCountryInfo(transferDetail.destinationCountryCode)
    }
    
    var selectedCurrency: SepaCurrencyInfo? {
        return sepaInfoList?.getSepaCurrencyInfo(transferDetail.transferAmount.currency?.currencyName)
    }
    
    init(transferDetail: BaseNoSepaPayeeDetailProtocol, account: Account?, operativeOrigin: ReemitedNoSepaTransferOrigin, accountType: String?) {
        self.transferDetail = transferDetail
        self.operativeOrigin = operativeOrigin
        self.accountType = accountType
        super.init(list: [], productSelected: account, titleKey: "toolbar_title_sendMoney", subTitleKey: "chargeDischarge_text_originAccountSelection")
    }
    
    func updatePre(accounts: [Account], sepaInfo: SepaInfoList) {
        self.list = accounts
        self.sepaInfoList = sepaInfo
    }
    
    var isSepaNoEur: Bool {
        var isSepa: Bool = false
        switch transferType {
        case .sepa?:
            isSepa = true
        case .identifier?:
            isSepa = false
        case .bicSwift?:
            isSepa = false
        case .none:
            isSepa = false
        }
        
        if amount?.currency?.currencyType != .eur && isSepa {
            return true
        }
        return false
    }
}
