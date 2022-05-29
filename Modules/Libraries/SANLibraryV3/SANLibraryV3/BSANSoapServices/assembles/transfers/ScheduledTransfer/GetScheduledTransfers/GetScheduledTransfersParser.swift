import Foundation
import Fuzi

public class GetScheduledTransfersParser : BSANParser<GetScheduledTransfersRespose, GetScheduledTransfersHandler> {
    override func setResponseData(){
        response.transferScheduledListDTO.transactionDTOs = handler.scheduledTransfersList
        response.transferScheduledListDTO.paginationDTO = handler.paginationDTO

    }
}

public class GetScheduledTransfersHandler: BSANHandler {
    
    var scheduledTransfersList : [TransferScheduledDTO] = []
    var paginationDTO = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let lista = result.firstChild(tag: "listaTransferencias"){
            for dato in lista.children(tag: "datosLista") {
                let scheduledTransferDTO = ScheduledTransferDTOParser.parse(dato)
                scheduledTransfersList.append(scheduledTransferDTO)
            }
        }
        paginationDTO = PaginationParser.parse(result)
    }
    
}
