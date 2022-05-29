import Foundation
import Fuzi
import SANLegacyLibrary

public class HistoricalCashWithdrawalParser : BSANParser <HistoricalCashWithdrawalResponse, HistoricalCashWithdrawalHandler> {
    override func setResponseData(){
        response.historicalWithdrawalDTO = handler.historicalWithdrawalDTO
    }
}

public class HistoricalCashWithdrawalHandler: BSANHandler {
    var historicalWithdrawalDTO = HistoricalWithdrawalDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let codResp = result.firstChild(tag: "codResp") {
            historicalWithdrawalDTO.codResp = DTOParser.safeInteger(codResp.stringValue.trim())
        }
        
        if let numHayMasDisp = result.firstChild(tag: "numHayMasDisp") {
            historicalWithdrawalDTO.numHayMasDisp = DTOParser.safeInteger(numHayMasDisp.stringValue.trim())
        }
        
        if let descListaActivadorClave = result.firstChild(tag: "descListaActivadorClave") {
            historicalWithdrawalDTO.descListaActivadorClave = descListaActivadorClave.stringValue.trim()
        }
        
        if let listaDispensaciones = result.firstChild(tag: "listaDispensaciones") {
            historicalWithdrawalDTO.dispensationList = [DispensationDTO]()
            
            if listaDispensaciones.children(tag: "dispensacion").count > 0 {
                var dispensationList: [DispensationDTO] = []
                for i in 0 ... listaDispensaciones.children(tag: "dispensacion").count - 1 {
                    let dispensacion = listaDispensaciones.children(tag: "dispensacion")[i]
                    var newDispensation = DispensationDTO()
                    
                    if let descFechaHoraPet = dispensacion.firstChild(tag: "descFechaHoraPet") {
                        newDispensation.descFechaHoraPet = DateFormats.safeDate(descFechaHoraPet.stringValue.trim(), format: DateFormats.TimeFormat.YYYYMMDD_T_HHmmss)
                    }
                    
                    if let numMensaje = dispensacion.firstChild(tag: "numMensaje") {
                        newDispensation.numMensaje = numMensaje.stringValue.trim()
                    }
                    
                    if let descPAN = dispensacion.firstChild(tag: "descPAN") {
                        newDispensation.descPAN = descPAN.stringValue.trim()
                    }
                    
                    if let descFechaHoraExp = dispensacion.firstChild(tag: "descFechaHoraExp") {
                        newDispensation.descFechaHoraExp = DateFormats.safeDate(descFechaHoraExp.stringValue.trim(), format: DateFormats.TimeFormat.YYYYMMDD_T_HHmmss)
                    }
                    
                    if let numEstado = dispensacion.firstChild(tag: "numEstado") {
                        newDispensation.numEstado = numEstado.stringValue.trim()
                    }
                    
                    if let impAdisp = dispensacion.firstChild(tag: "impAdisp"), let amountValue = AmountDTOParser.safeDecimal(impAdisp.stringValue) {
                        let normalized = NSDecimalNumber(decimal: amountValue).dividing(by: NSDecimalNumber(value: 100.0)).decimalValue
                        newDispensation.impAdisp = AmountDTO(value: normalized, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    dispensationList.append(newDispensation)
                }
                historicalWithdrawalDTO.dispensationList = dispensationList
            }
        }
    }
}

