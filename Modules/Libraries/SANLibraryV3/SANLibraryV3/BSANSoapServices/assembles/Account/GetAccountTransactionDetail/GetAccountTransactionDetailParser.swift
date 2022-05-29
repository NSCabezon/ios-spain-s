import Foundation

import Fuzi

public class GetAccountTransactionDetailParser : BSANParser <GetAccountTransactionDetailResponse, GetAccountTransactionDetailHandler> {
    override func setResponseData(){
        response.accountTransactionDetailDTO = handler.accountTransactionDetailDTO
        
        let literalDTOs: [LiteralDTO] = handler.literalConceptosDTOs.enumerated().compactMap {
            guard $0.offset < handler.conceptosDTOs.count else { return nil }
            return LiteralDTO(concept: handler.conceptosDTOs[$0.offset],
                              literal: $0.element)
        }
        response.accountTransactionDetailDTO.literalDTOs = literalDTOs
    }
}

public class GetAccountTransactionDetailHandler: BSANHandler {
    
    var accountTransactionDetailDTO = AccountTransactionDetailDTO()
    var literalConceptosDTOs = [String]()
    var conceptosDTOs = [String]()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "titulo":
            accountTransactionDetailDTO.title = element.stringValue.trim()
        default:
            BSANLogger.e("\(#function)", "Nodo Sin Parsear! -> \(tag)")
        }
        
        if tag.starts(with: "literalConcepto"){
            literalConceptosDTOs.append(element.stringValue.trim())
        }
        else if tag.starts(with: "concepto"){
            conceptosDTOs.append(element.stringValue.trim())
        }
    }
}
