import Foundation
import SANLegacyLibrary

struct EasyPayAmortizationQueryInputDTO: Encodable  {
    let cdempre, cdempred, centalta, cdproduc, cdfinanc: String?
    let cuentad, controlOperativoContrato, controlOperativoCliente, clamon1: String?
    let cuotano, nuextcta, numvtoex: Int?
    let enero1, febrero1, marzo1, abril1: String?
    let mayo1, junio1, julio1, agosto1: String?
    let eptiemb1, octubre1, noviemb1, diciemb1: String?
    
    public init(input: EasyPayAmortizationRequestParams) {
        self.cdempre = input.cdempre
        self.cdempred = input.cdempred
        self.centalta = input.centalta
        self.cdproduc = input.cdproduc
        self.cuentad = input.cuentad
        self.controlOperativoContrato = input.controlOperativoContrato
        self.controlOperativoCliente = input.controlOperativoCliente
        self.clamon1 = input.clamon1
        self.cuotano = input.cuotano
        self.nuextcta = input.nuextcta
        self.numvtoex = input.numvtoex
        self.cdfinanc = "PFCM"
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
