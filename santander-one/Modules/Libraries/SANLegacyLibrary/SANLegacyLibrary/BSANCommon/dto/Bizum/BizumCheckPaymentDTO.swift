//

import Foundation

public struct BizumCheckPaymentDTO: Codable {
    public let phone: String
    public let contractIdentifier: BizumCheckPaymentContractDTO
    public let initialDate: Date
    public let endDate: Date
    public let back: String?
    public let message: String?
    public let ibanCode: BizumCheckPaymentIBANDTO
    public let offset: String?
    public let offsetState: String?
    public let indMigrad: String?
    public let xpan: String?
    
    public init(
        phone: String,
        contractIdentifier: BizumCheckPaymentContractDTO,
        initialDate: Date,
        endDate: Date,
        back: String?,
        message: String?,
        ibanCode: BizumCheckPaymentIBANDTO,
        offset: String?,
        offsetState: String?,
        indMigrad: String?,
        xpan: String?
    ) {
        self.phone = phone
        self.contractIdentifier = contractIdentifier
        self.initialDate = initialDate
        self.endDate = endDate
        self.back = back
        self.message = message
        self.ibanCode = ibanCode
        self.offset = offset
        self.offsetState = offsetState
        self.indMigrad = indMigrad
        self.xpan = xpan
    }
    
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
}

extension BizumCheckPaymentDTO: DateParseable {
    
    public static var formats: [String: String] {
        return [
            "fechaAlta": "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "fechaFinVigencia": "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
    }
}
