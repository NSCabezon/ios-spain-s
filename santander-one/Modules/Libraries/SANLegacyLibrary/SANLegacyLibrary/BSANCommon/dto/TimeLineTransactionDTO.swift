//

import CoreDomain
import Foundation

public struct TimeLineTransactionDTO: Codable {
    public var type: TimeLineTransactionTypeDTO
    public var description: String
    public var date: DateModel
    
    enum CodingKeys: String, CodingKey {
        case type
        case description
        case date
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let dateValue = try values.decode(String.self, forKey: .date)
        let descrValue = try values.decode(String.self, forKey: .description)
        let typeValue = try values.decodeIfPresent(String.self, forKey: .type)
        if let dateInstance = DateFormats.safeDate(dateValue, format: .YYYYMMDD) {
            date = DateModel(date: dateInstance)
        } else {
            throw BSANException("Error parsing dateInstance")
        }
        description = descrValue
        type = TimeLineTransactionTypeDTO(rawValue: typeValue ?? "000") ?? .unknown
    }
}

public enum TimeLineTransactionTypeDTO: String,  Codable {
    case trPunctualEmitted = "100"
    case trPunctualReceived = "111"
    case trScheduled = "101"
    case receipt = "102"
    case cardSubscription = "103"
    case mortage = "104"
    case loan = "105"
    case insurance = "106"
    case pensionPlan = "107"
    case cardClearing = "108"
    case bizumReceived = "112"
    case bizumEmitted = "109"
    case payslip = "200"
    case alta = "300"
    case baja = "301"
    case expiration = "302"
    case expiry = "303"
    case unknown = "000"
}

/*
 100 - Transferencia puntual emitida
 111 - Transferencia puntual recibida
 101 - Transferencia programada (vendrian siempre con signo positivo)
 102 - Recibo
 103 - Subscripción de tarjeta
 104 - Hipoteca
 105 - Préstamo
 106 - Seguro
 107 - Plan de pensiones
 108 - Liquidación de tarjeta
 109 - Bizum recibido
 112 - Bizum emitido
 200 - Nómina
 300 - Alta
 301 - Baja
 302 - Caducidad
 303 - Vencimiento
 000 – Desconocido
 */
