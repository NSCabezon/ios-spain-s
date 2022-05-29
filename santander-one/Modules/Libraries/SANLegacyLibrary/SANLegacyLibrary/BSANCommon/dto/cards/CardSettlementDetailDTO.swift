//

import Foundation

public struct CardSettlementDetailDTO: Codable {
    public var startDate: Date?
    public var endDate: Date?
    public var ascriptionDate: Date?
    public var paymentMethodSettlement: Int?
    public var paymentMethodCard: Int?
    public var actualDeposit: Double?
    public var totalAmount: Double?
    public var commission: Double?
    public var interest: Double?
    public var capital: Double?
    public var authorizedATM: Double?
    public var extractNumber: Int?
    public var errorCode: Int?
    
    private enum CodingKeys: String, CodingKey {
        case startDate = "fechaIniLiquidacion"
        case endDate = "fechaFinLiquidacion"
        case ascriptionDate = "fechaImputacion"
        case paymentMethodSettlement = "formaPagoLiquidacionConsultada"
        case paymentMethodCard = "formaPagoTarjetaConsultada"
        case actualDeposit = "dispuestoActual"
        case totalAmount = "importeTotalLiquidacion"
        case commission = "comisionLiquidacion"
        case interest = "interesLiquidacion"
        case capital = "capital"
        case authorizedATM = "autorizadoCajeros"
        case extractNumber = "numeroExtracto"
    }
    
    public init(errorCode: Int) {
        self.errorCode = errorCode
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let startDateString = try? values.decode(String.self, forKey: .startDate){
            self.startDate = DateFormats.toDate(string: startDateString, output: DateFormats.TimeFormat.YYYYMMDD)
        }
        if let endDateString = try? values.decode(String.self, forKey: .endDate){
            self.endDate = DateFormats.toDate(string: endDateString, output: DateFormats.TimeFormat.YYYYMMDD)
        }
        if let ascriptionDateString = try? values.decode(String.self, forKey: .ascriptionDate){
            self.ascriptionDate = DateFormats.toDate(string: ascriptionDateString, output: DateFormats.TimeFormat.YYYYMMDD)
        }
        paymentMethodSettlement = try values.decode(Int.self, forKey: .paymentMethodSettlement)
        paymentMethodCard = try values.decode(Int.self, forKey: .paymentMethodCard)
        actualDeposit = try values.decode(Double.self, forKey: .actualDeposit)
        totalAmount = try values.decode(Double.self, forKey: .totalAmount)
        commission = try values.decode(Double.self, forKey: .commission)
        interest = try values.decode(Double.self, forKey: .interest)
        capital = try values.decode(Double.self, forKey: .capital)
        authorizedATM = try values.decode(Double.self, forKey: .authorizedATM)
        extractNumber = try values.decode(Int.self, forKey: .extractNumber)
    }
}
