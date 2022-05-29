//
//  BizumCheckPaymentDto.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 12/5/21.
//

import CoreDomain
import SANSpainLibrary
import SANServicesLibrary

struct BizumCheckPaymentDto {
    
    struct CenterDto: CenterRepresentable, Decodable {
        let company: String
        let center: String
        
        private enum CodingKeys: String, CodingKey {
            case center = "centro"
            case company = "empresa"
        }
    }
    
    struct ContractDto: BizumCheckPaymentContractRepresentable, Decodable {
        let subGroup: String
        let contractNumber: String
        let centerDto: CenterDto
        var center: CenterRepresentable {
            return self.centerDto
        }
        
        private enum CodingKeys: String, CodingKey {
            case centerDto = "centro"
            case subGroup = "subgrupo"
            case contractNumber = "numerodecontrato"
        }
    }
    
    struct IbanDto: BizumCheckPaymentIbanRepresentable, Decodable {
        let country: String
        let controlDigit: String
        let codbban: String
        
        private enum CodingKeys: String, CodingKey {
            case country = "pais"
            case controlDigit = "digitodecontrol"
            case codbban
        }
    }
    
    let phone: String
    let initialDate: Date
    let endDate: Date
    let back: String?
    let message: String?
    let offset: String?
    let offsetState: String?
    let indMigrad: String?
    let xpan: String?
    let contractIdentifier: ContractDto
    let ibanCode: IbanDto
    
    private enum CodingKeys: String, CodingKey {
        case phone = "telfMovil"
        case contractIdentifier = "identificadorContrato"
        case initialDate = "fechaAlta"
        case endDate = "fechaFinVigencia"
        case back = "retorno"
        case message = "mensaje"
        case ibanCode = "codIBAN"
        case offset
        case offsetState = "estadoOffset"
        case indMigrad
        case xpan
    }
    
    init(checkpayment: BizumCheckPaymentDto, xpan: String?) {
        self.phone = checkpayment.phone
        self.initialDate = checkpayment.initialDate
        self.endDate = checkpayment.endDate
        self.back = checkpayment.back
        self.message = checkpayment.message
        self.offset = checkpayment.offset
        self.offsetState = checkpayment.offsetState
        self.indMigrad = checkpayment.indMigrad
        self.xpan = xpan ?? checkpayment.xpan
        self.contractIdentifier = checkpayment.contractIdentifier
        self.ibanCode = checkpayment.ibanCode
    }
}

extension BizumCheckPaymentDto: BizumCheckPaymentRepresentable, Decodable {
    var contract: BizumCheckPaymentContractRepresentable {
        return self.contractIdentifier
    }
    var iban: BizumCheckPaymentIbanRepresentable {
        return self.ibanCode
    }
}

extension BizumCheckPaymentDto: DateParseable {
    public static var formats: [String: String] {
        return [
            "fechaAlta": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "fechaFinVigencia": "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
    }
}
