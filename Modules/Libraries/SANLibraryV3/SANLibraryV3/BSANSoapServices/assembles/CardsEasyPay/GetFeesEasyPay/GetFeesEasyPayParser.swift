import Foundation
import Fuzi

public class GetFeesEasyPayParser : BSANParser <GetFeesEasyPayResponse, GetFeesEasyPayHandler> {
    override func setResponseData(){
        response.feeDataDTO = handler.feeDataDTO
    }
}

public class GetFeesEasyPayHandler: BSANHandler {
    
    var feeDataDTO = FeeDataDTO()
    
    override func parseResult(result: XMLElement) throws {
        
        if let datosCuota = result.firstChild(tag: "datosCuota") {
            if let numPlazoMin = datosCuota.firstChild(tag: "numPlazoMin") {
                feeDataDTO.minPeriodCount = DTOParser.safeInteger(numPlazoMin.stringValue)
            }
            
            if let numPlazoMax = datosCuota.firstChild(tag: "numPlazoMax") {
                feeDataDTO.maxPeriodCount = DTOParser.safeInteger(numPlazoMax.stringValue)
            }
            
            if let numPlazoInc_NPLAZINC = datosCuota.firstChild(tag: "numPlazoInc_NPLAZINC") {
                feeDataDTO.periodInc = DTOParser.safeInteger(numPlazoInc_NPLAZINC.stringValue)
            }
            
            if let importeMinimoCuota = datosCuota.firstChild(tag: "importeMinimoCuota") {
                feeDataDTO.minFeeAmount = importeMinimoCuota.stringValue.trim()
            }
            
            if let JPORCEA1 = datosCuota.firstChild(tag: "JPORCEA1") {
                feeDataDTO.JPORCEA1 = JPORCEA1.stringValue.trim()
            }
            
            if let JTIPOLI = datosCuota.firstChild(tag: "JTIPOLI") {
                feeDataDTO.JTIPOLI = JTIPOLI.stringValue.trim()
            }
            
            if let JTIPRAN = datosCuota.firstChild(tag: "JTIPRAN") {
                feeDataDTO.JTIPRAN = JTIPRAN.stringValue.trim()
            }
            
            if let LIMITPO1 = datosCuota.firstChild(tag: "LIMITPO1") {
                feeDataDTO.LIMITPO1 = LIMITPO1.stringValue.trim()
            }
            
            if let MLFORPA1 = datosCuota.firstChild(tag: "MLFORPA1") {
                feeDataDTO.MLFORPA1 = MLFORPA1.stringValue.trim()
            }
        }
    }
}
