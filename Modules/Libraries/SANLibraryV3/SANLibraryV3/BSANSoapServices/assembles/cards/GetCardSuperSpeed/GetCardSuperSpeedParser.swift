import Foundation
import Fuzi

public class GetCardSuperSpeedParser : BSANParser <GetCardSuperSpeedResponse, GetCardSuperSpeedHandler> {
    override func setResponseData(){
        response.cardSuperSpeedListDTO = CardSuperSpeedListDTO(cards: handler.cardSuperSpeedDTOs, pagination: handler.pagination)
    }
}

public class GetCardSuperSpeedHandler: BSANHandler {
    var cardSuperSpeedDTOs = [CardSuperSpeedDTO]()
    var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista") {
            if lista.children(tag: "datos").count > 0 {
                for datosChild in lista.children(tag: "datos") {
                    var newCard = CardSuperSpeedDTO()
                    
                    if let numeroTarjeta = datosChild.firstChild(tag: "numeroTarjeta"){
                        newCard.PAN = numeroTarjeta.stringValue.trim()
                    }
                    if let codigoPlastico = datosChild.firstChild(tag: "codigoPlastico"){
                        newCard.visualCode = codigoPlastico.stringValue.trim()
                    }
                    if let nombreDeEstampacion = datosChild.firstChild(tag: "nombreDeEstampacion"){
                        newCard.stampingName = nombreDeEstampacion.stringValue.trim()
                    }
                    if let limiteCredito = datosChild.firstChild(tag: "limiteCredito"){
                        newCard.creditLimitAmount = AmountDTOParser.parse(limiteCredito)
                    }
                    if let saldoDispuesto = datosChild.firstChild(tag: "saldoDispuesto"){
                        // ñapa obligatoria balance de crédito viene positivo
                        var creditBalance = AmountDTOParser.parse(saldoDispuesto)
                        if var value = creditBalance.value {
                            value.negate()
                            creditBalance.value = value
                            newCard.currentBalance = creditBalance
                        }
                    }
                    if let saldoDisponible = datosChild.firstChild(tag: "saldoDisponible"){
                        newCard.availableAmount = AmountDTOParser.parse(saldoDisponible)
                    }
                    if let indActiva = datosChild.firstChild(tag: "indActiva"){
                        newCard.indActive = indActiva.stringValue.trim()
                    }
                    if let indBloqueo = datosChild.firstChild(tag: "indBloqueo"){
                        newCard.indBlocking = indBloqueo.stringValue.trim()
                    }
                    if let marca = datosChild.firstChild(tag: "marca"){
                        newCard.mark = marca.stringValue.trim()
                    }
                    if let tipoTarjeta = datosChild.firstChild(tag: "tipoTarjeta"){
                        newCard.cardType = tipoTarjeta.stringValue.trim()
                    }
                    if let fechaCaduc = datosChild.firstChild(tag: "fechaCaduc"){
                        newCard.expirationDate = fechaCaduc.stringValue.trim()
                    }
                    if let marcaTiempo = datosChild.firstChild(tag: "marcaTiempo"){
                        newCard.timeMark = marcaTiempo.stringValue
                    }
                    if let fechaAutorizacionDiaria = datosChild.firstChild(tag: "fechaAutorizacionDiaria"){
                        newCard.dateAuthorizationDay = DateFormats.safeDate(fechaAutorizacionDiaria.stringValue)
                    }
                    if let impLImitempCredDiario = datosChild.firstChild(tag: "impLImitempCredDiario"){
                        newCard.temporaryLimitDailyCredit = AmountDTOParser.parse(impLImitempCredDiario)
                    }
                    if let impLimCredDiario = datosChild.firstChild(tag: "impLimCredDiario"){
                        newCard.limitDailyCredit = AmountDTOParser.parse(impLimCredDiario)
                    }
                    if let impLimCredDiarioMax = datosChild.firstChild(tag: "impLimCredDiarioMax"){
                        newCard.limitMaximumDailyCredit = AmountDTOParser.parse(impLimCredDiarioMax)
                    }
                    if let impLimCredMensualMax = datosChild.firstChild(tag: "impLimCredMensualMax"){
                        newCard.limitMaximumMonthlyCredit = AmountDTOParser.parse(impLimCredMensualMax)
                    }
                    if let impLimCredMensual = datosChild.firstChild(tag: "impLimCredMensual"){
                        newCard.limitMonthlyCredit = AmountDTOParser.parse(impLimCredMensual)
                    }
                    if let impLimCredTarjeta = datosChild.firstChild(tag: "impLimCredTarjeta"){
                        newCard.limitCreditCard = AmountDTOParser.parse(impLimCredTarjeta)
                    }
                    if let impLimitempCredMensual = datosChild.firstChild(tag: "impLimitempCredMensual"){
                        newCard.temporaryLimitMonthlyCredit = AmountDTOParser.parse(impLimitempCredMensual)
                    }
                    if let impLimitempDebDiario = datosChild.firstChild(tag: "impLimitempDebDiario"){
                        newCard.temporaryLimitDailyDebit = AmountDTOParser.parse(impLimitempDebDiario)
                    }
                    if let impLimitempDebMensual = datosChild.firstChild(tag: "impLimitempDebMensual"){
                        newCard.temporaryLimitMonthlyDebit = AmountDTOParser.parse(impLimitempDebMensual)
                    }
                    if let impLimDebDiario = datosChild.firstChild(tag: "impLimDebDiario"){
                        newCard.dailyDebitLimit = AmountDTOParser.parse(impLimDebDiario)
                    }
                    if let impLimDebDiarioMax = datosChild.firstChild(tag: "impLimDebDiarioMax"){
                        newCard.maximumDailyDebitLimit = AmountDTOParser.parse(impLimDebDiarioMax)
                    }
                    if let impLimDebMensualMax = datosChild.firstChild(tag: "impLimDebMensualMax"){
                        newCard.maximumMonthlyDebitLimit = AmountDTOParser.parse(impLimDebMensualMax)
                    }
                    if let impLimDebMensual = datosChild.firstChild(tag: "impLimDebMensual"){
                        newCard.limitMonthlyDebit = AmountDTOParser.parse(impLimDebMensual)
                    }
                    if let impLimDiarioCajero = datosChild.firstChild(tag: "impLimDiarioCajero"){
                        newCard.dailyCashierLimit = AmountDTOParser.parse(impLimDiarioCajero)
                    }
                    if let impLimDiarioCajeroMax = datosChild.firstChild(tag: "impLimDiarioCajeroMax"){
                        newCard.maximumDailyCashierLimit = AmountDTOParser.parse(impLimDiarioCajeroMax)
                    }
                    if let numLimOperDia = datosChild.firstChild(tag: "numLimOperDia"){
                        newCard.numberLimitOperationsDay = numLimOperDia.stringValue.trim()
                    }
                    if let numMaxOperDia = datosChild.firstChild(tag: "numMaxOperDia"){
                        newCard.numberMaximumOperationsDay = numMaxOperDia.stringValue.trim()
                    }
                    if let numLimOperMes = datosChild.firstChild(tag: "numLimOperMes"){
                        newCard.numberLimitOperationsMonth = numLimOperMes.stringValue.trim()
                    }
                    if let numMaxOperMes = datosChild.firstChild(tag: "numMaxOperMes"){
                        newCard.numberMaximumOperationsMonth = numMaxOperMes.stringValue.trim()
                    }
                    if let numLimOperDiaCaj = datosChild.firstChild(tag: "numLimOperDiaCaj"){
                        newCard.numberLimitOperationsDayCashier = numLimOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "numMaxOperDiaCaj"){
                        newCard.numberMaximumOperationsDayCashier = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechInicTempCred"){
                        newCard.temporaryLimitCreditStart = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechFinTempCred"){
                        newCard.temporaryLimitCreditEnd = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechInicTempCredMen"){
                        newCard.temporaryLimitCreditMonthStart = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechFinTempCredMen"){
                        newCard.temporaryLimitCreditMonthEnd = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechInicTempCredDia"){
                        newCard.temporaryLimitCreditDayStart = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechFinTempCredDia"){
                        newCard.temporaryLimitCreditDayEnd = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechInicTempDebMen"){
                        newCard.temporaryLimitDebitMonthStart = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechFinTempDebMen"){
                        newCard.temporaryLimitDebitMonthEnd = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechInicTempDebDia"){
                        newCard.temporaryLimitDebitDayStart = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let numMaxOperDiaCaj = datosChild.firstChild(tag: "fechFinTempDebDia"){
                        newCard.temporaryLimitDebitDayEnd = numMaxOperDiaCaj.stringValue.trim()
                    }
                    if let qualityParticipation = datosChild.firstChild(tag: "calidadParticipacion") {
                        newCard.qualityParticipation = qualityParticipation.stringValue.trim()
                    }
                    cardSuperSpeedDTOs.append(newCard)
                }
            }
            
            if let repo = result.firstChild(tag: "repo") {
                pagination.repositionXML = repo.description.replace("repo", "repos")
                
                if let finLista = repo.firstChild(tag: "finLista") {
                    pagination.endList = DTOParser.safeBoolean(finLista.stringValue.trim())
                }
            }
        }
        
    }
}
