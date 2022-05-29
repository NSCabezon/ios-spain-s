import Foundation
import Fuzi

public class GetEmittedTransfersParser : BSANParser<GetEmittedTransfersResponse, GetEmittedTransfersHandler> {
    override func setResponseData(){
        response.transferEmittedListDTO.transactionDTOs  = handler.transferEmittedList
        response.transferEmittedListDTO.paginationDTO = handler.paginationDTO
    }
}

public class GetEmittedTransfersHandler: BSANHandler {
    
    var transferEmittedList : [TransferEmittedDTO] = []
    var paginationDTO = PaginationDTO()
    
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "lista"){
            for dato in lista.children(tag: "transferencia") {
                let transferEmittedDTO = TransferEmittedDTOParser.parse(dato)
                transferEmittedList.append(transferEmittedDTO)
            }
        }
        paginationDTO = PaginationParser.parse(result)
    }
    
}
