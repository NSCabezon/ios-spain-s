import Foundation
import Fuzi

class FundTransferResponseDataDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> FundTransferResponseDataDTO {
        var fundTransferResponseDataDTO = FundTransferResponseDataDTO()
        
        if let numPersonaAcceso = node.firstChild(tag: "numPersonaAcceso") {
            fundTransferResponseDataDTO.accessPersonNumber = ClientDTOParser.parse(numPersonaAcceso)
        }
        
        if let codigoFondoDestino = node.firstChild(tag: "codigoFondoDestino") {
            fundTransferResponseDataDTO.destinationFundCode = codigoFondoDestino.stringValue.trim()
        }
        
        if let nombreFondoDestino = node.firstChild(tag: "nombreFondoDestino") {
            fundTransferResponseDataDTO.destinationFundName = nombreFondoDestino.stringValue.trim()
        }
        
        if let fechaValor = node.firstChild(tag: "fechaValor") {
            fundTransferResponseDataDTO.valueDate = DateFormats.safeDate(fechaValor.stringValue, format: DateFormats.TimeFormat.DDMMYYYY)
        }
        
        if let tipoTraspasoSegunGestora = node.firstChild(tag: "tipoTraspasoSegunGestora") {
            fundTransferResponseDataDTO.transferTypeByManagingCompany = tipoTraspasoSegunGestora.stringValue.trim()
        }
        
        if let cantidadPorRepartir = node.firstChild(tag: "cantidadPorRepartir") {
            fundTransferResponseDataDTO.quantityToSplit = cantidadPorRepartir.stringValue.trim()
        }
        
        if let cantidadTraspasoParcial = node.firstChild(tag: "cantidadTraspasoParcial") {
            fundTransferResponseDataDTO.partialTransferQuantity = cantidadTraspasoParcial.stringValue.trim()
        }
        
        if let codigoIsinOrigen = node.firstChild(tag: "codigoIsinOrigen") {
            fundTransferResponseDataDTO.originIsinCode = codigoIsinOrigen.stringValue.trim()
        }
        
        if let codigoCifGestoraOrigen = node.firstChild(tag: "codigoCifGestoraOrigen") {
            fundTransferResponseDataDTO.originManagingCompanyCIF = codigoCifGestoraOrigen.stringValue.trim()
        }
        
        if let contador = node.firstChild(tag: "contador") {
            fundTransferResponseDataDTO.counter = contador.stringValue.trim()
        }
        
        if let importeDispMonedaFondo = node.firstChild(tag: "importeDispMonedaFondo") {
            fundTransferResponseDataDTO.fundCurrencyAvailableAmount = AmountDTOParser.parse(importeDispMonedaFondo)
        }
        
        if let participacionesFondo = node.firstChild(tag: "participacionesFondo") {
            fundTransferResponseDataDTO.fundShares = participacionesFondo.stringValue.trim()
        }
        
        if let participacionesTraspaso = node.firstChild(tag: "participacionesTraspaso") {
            fundTransferResponseDataDTO.transferShares = participacionesTraspaso.stringValue.trim()
        }
        
        if let saldoParticipacionesDebe = node.firstChild(tag: "saldoParticipacionesDebe") {
            fundTransferResponseDataDTO.debitSharesBalance = saldoParticipacionesDebe.stringValue.trim()
        }
        
        return fundTransferResponseDataDTO
    }
}
