import Foundation
import Fuzi

public class GetSociusDetailAccountsAllParser : BSANParser<GetSociusDetailAccountsAllResponse, GetSociusDetailAccountsAllHandler> {
    override func setResponseData(){
        response.sociusAccountDetailDTO = handler.sociusAccountDetailDTO
    }
}

public class GetSociusDetailAccountsAllHandler: BSANHandler {
    
    var sociusAccountDetailDTO: SociusAccountDetailDTO = SociusAccountDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "cuentasSocius":
            let sociusAccountDTO = SociusAccountDTOParser.parse(element)
            if sociusAccountDTO.accountType != nil {
                sociusAccountDetailDTO.sociusAccountList.append(sociusAccountDTO)
            }
            break
        case "liquidacionTotal":
            sociusAccountDetailDTO.totalLiquidation = SociusLiquidationDTOParser.parse(element)
            break
        case "liquidacionParticulares":
            sociusAccountDetailDTO.particularLiquidation = SociusLiquidationDTOParser.parse(element)
            break
        case "liquidacionPymes":
            sociusAccountDetailDTO.pymesLiquidation = SociusLiquidationDTOParser.parse(element)
            break
        case "liquidacionMini":
            sociusAccountDetailDTO.miniLiquidation = SociusLiquidationDTOParser.parse(element)
            break
        case "liquidacionSmartPremium":
            sociusAccountDetailDTO.smartLiquidation = SociusLiquidationDTOParser.parse(element)
            break
        default:
            BSANLogger.e("GetSociusDetailAccountsAllParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
