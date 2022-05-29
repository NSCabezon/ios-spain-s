import Foundation
import CoreFoundationLib

class UsualTransferOperativeData: ProductSelection<Account> {
    let originTransfer: Favourite
    var sepaList: SepaInfoList?
    var currency: SepaCurrencyInfo? = SepaCurrencyInfo.createEuro()//TODO: Fijado momentaneamente. Más adelante sera asignado por la operativa (NO SEPA)
    var country: SepaCountryInfo?
    var maxImmediateNationalAmount: Amount?
    var amount: Amount?
    var concept: String?
    var subType: OnePayTransferSubType?
    var type: OnePayTransferType? {
        guard let country = country, let currency = currency else {
            return nil
        }
        if country.code == "ES" && currency.code == "EUR" {
            return .national
        } else if country.sepa && currency.code == "EUR" {
            return .sepa
        } else {
            return .noSepa
        }
    }
    var beneficiaryMail: String?
    var summaryState: OnePayTransferSummaryState?
    var transferNational: TransferNational?
    var transferConfirmAccount: TransferConfirmAccount?
    var time: OnePayTransferTime? = .now
    var payer: String?
    var faqs: [FaqsEntity]?
    var isBackToOriginEnabled = false
    var listNotVisibles: [Account]?
    var commission: Amount?
    
    init(account: Account?, originTransfer: Favourite) {
        self.originTransfer = originTransfer
        super.init(list: [], productSelected: account, titleKey: "toolbar_title_sendMoney", subTitleKey: "chargeDischarge_text_originAccountSelection")
    }
    
    func updatePre(accounts: [Account], accountNotVisibles: [Account]? = nil, sepaList: SepaInfoList, faqs: [FaqsEntity]?) {
        self.list = accounts
        self.listNotVisibles = accountNotVisibles
        self.sepaList = sepaList
        self.faqs = faqs
        self.country = sepaList.allCountries.first {
            return originTransfer.iban?.countryCode == $0.code
        }
    }
    
    func update(maxImmediateNationalAmount: Amount?) {
        self.maxImmediateNationalAmount = maxImmediateNationalAmount
    }
    
    func setAccount(_ accountEntity: AccountEntity) {
        self.productSelected = Account.create(accountEntity.dto)
    }
}

extension UsualTransferOperativeData: TransferOperativeData {
    var beneficiary: String? {
        return name
    }
    var account: Account? {
        return productSelected
    }
    var iban: IBAN? {
        return originTransfer.iban
    }
    var issueDate: Date? {
        return transferNational?.issueDate
    }
    var bankChargeAmount: Amount? {
        return transferNational?.bankChargeAmount
    }
    var expensesAmount: Amount? {
        return transferNational?.expensesAmount
    }
    var netAmount: Amount? {
        return transferNational?.netAmount
    }
    var transferAmount: Amount? {
        return transferNational?.transferAmount
    }
    var name: String? {
        return originTransfer.baoName
    }
    var isModifyOriginAccountEnabled: Bool { !self.isProductSelectedWhenCreated }
    var isModifyDestinationAccountEnabled: Bool { false }
    var isModifyCountryEnabled: Bool { false }
    var isModifyPeriodicityEnabled: Bool { false }
    var isModifyConceptEnabled: Bool { false }
    var isBiometryEnabled: Bool { false }
    var isTouchIdEnabled: Bool { false }
    var isCorrectFingerFlag: Bool { false }
}
