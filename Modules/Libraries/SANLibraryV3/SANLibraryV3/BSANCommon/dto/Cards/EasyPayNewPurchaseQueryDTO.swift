import Foundation
import SANLegacyLibrary

struct EasyPayNewPurchaseQueryDTO: Encodable  {
    let cdempre: String?
    let cdempred: String?
    let cdfinanc: String?
    let cdproduc: String?
    let centalta: String?
    let clamon1: String?
    let controlOperativoContrato: String?
    let cuentad: String?
    let cuotano: Int?
    let nuextcta: Int?
    let numvtoex: Int?
    let mesdat: [String]?
    
    public init(card: CardDTO, input: BuyFeesParameters) {
        self.cdempre = card.contract?.bankCode
        self.cdempred = card.contract?.bankCode
        self.cdfinanc = "PFCM"
        self.cdproduc = card.contract?.product
        self.centalta = card.contract?.branchCode
        self.clamon1 = card.currency?.currencyType.rawValue ?? SharedCurrencyType.default.rawValue
        self.controlOperativoContrato = card.contractDescription?.replacingOccurrences(of: " ", with: "")
        self.cuentad = card.contract?.contractNumber
        self.cuotano = Int(input.numFees)
        self.nuextcta = Int(input.balanceCode)
        self.numvtoex = Int(input.transactionDay)
        self.mesdat = ["0099"]
    }
}
