//

import Foundation
import SANLegacyLibrary

struct EasyPayFeesQueryDTO: Encodable  {
    
    let cdempred, cdfinanc, cdempre, centalta: String?
    let cdproduc, cuentad, clamon1, controlOperativoContrato: String?
    let cuotano, nuextcta, numvtoex: Int?
    let enero1, febrero1, marzo1, abril1: String?
    let mayo1, junio1, julio1, agosto1: String?
    let eptiemb1, octubre1, noviemb1, diciemb1: String?
    
    
    public init(card: CardDTO, input: BuyFeesParameters) {
        self.cdempred = card.contract?.bankCode ?? ""
        self.cdfinanc = "PFCM"
        self.cdempre = card.contract?.bankCode ?? ""
        self.centalta = card.contract?.branchCode ?? ""
        self.cdproduc = card.contract?.product ?? ""
        self.cuentad = card.contract?.contractNumber ?? ""
        self.clamon1 = card.currency?.currencyType.rawValue ?? SharedCurrencyType.default.rawValue
        self.controlOperativoContrato = card.contractDescription?.replacingOccurrences(of: " ", with: "") ?? ""
        self.cuotano = Int(input.numFees)
        self.nuextcta = Int(input.balanceCode)
        self.numvtoex = Int(input.transactionDay)
        self.enero1 = "S"
        self.febrero1 = "S"
        self.marzo1 = "S"
        self.abril1 = "S"
        self.mayo1 = "S"
        self.junio1 = "S"
        self.julio1 = "S"
        self.agosto1 = "S"
        self.eptiemb1 = "S"
        self.octubre1 = "S"
        self.noviemb1 = "S"
        self.diciemb1 = "S"
    }
}
