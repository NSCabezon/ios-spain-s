import Foundation
import Fuzi

public class GetLiquidationDetailParser : BSANParser <GetLiquidationDetailResponse, GetLiquidationDetailHandler> {
    override func setResponseData(){
        response.liquidationDetailDTO = handler.liquidationDetailDTO
    }
}

public class GetLiquidationDetailHandler: BSANHandler {
    
    var liquidationDetailDTO = LiquidationDetailDTO()
    
    override func parseResult(result: XMLElement) throws {

        if let lista = result.firstChild(tag: "lista"){
            var liquidationItemDetailDTOList: [LiquidationItemDetailDTO] = []
            
            if lista.children(tag: "dato").count > 0{
                for i in 0 ... lista.children(tag: "dato").count - 1{
                    liquidationItemDetailDTOList.append(LiquidationItemDetailDTOParser.parse(lista.children(tag: "dato")[i]))
                }
                liquidationDetailDTO.liquidationItemDetailDTOList = liquidationItemDetailDTOList
            }
        }
        
        if let totalHaber = result.firstChild(tag: "totalHaber"){
            liquidationDetailDTO.totalCredit = AmountDTOParser.parse(totalHaber)
        }
        
        if let totalDebe = result.firstChild(tag: "totalDebe"){
            liquidationDetailDTO.totalDebit = AmountDTOParser.parse(totalDebe)
        }
    }
}
