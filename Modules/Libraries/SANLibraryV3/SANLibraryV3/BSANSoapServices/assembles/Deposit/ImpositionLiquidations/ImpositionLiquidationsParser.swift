import Foundation
import Fuzi

public class ImpositionLiquidationsParser: BSANParser<ImpositionLiquidationsResponse, ImpositionLiquidationsHandler> {
    override func setResponseData() {
        setAllCurrencies(liquidationTransactionListDTO: &handler.liquidationTransactionListDTO)
        response.liquidationTransactionListDTO = handler.liquidationTransactionListDTO
    }

    func setAllCurrencies(liquidationTransactionListDTO: inout LiquidationTransactionListDTO) {
        if var liquidations = liquidationTransactionListDTO.liquidationDTOS, let amount = liquidations[0].settlementAmount, let currency = amount.currency {
            for i in 0...liquidations.count - 1  {
                liquidations[i].settlementAmount?.currency = currency
            }
            liquidationTransactionListDTO.liquidationDTOS = liquidations
        }
    }
}

public class ImpositionLiquidationsHandler: BSANHandler {

    var liquidationTransactionListDTO = LiquidationTransactionListDTO()

    override func parseResult(result: XMLElement) throws {

        if let lista = result.firstChild(tag: "lista") {
            if lista.children(tag: "dato").count > 0 {
                var liquidationDTOS: [LiquidationDTO] = []
                for i in 0...lista.children(tag: "dato").count - 1 {
                    let node = lista.children(tag: "dato")[i]
                    liquidationDTOS.append(LiquidationDTOParser.parse(node))
                }
                liquidationTransactionListDTO.liquidationDTOS = liquidationDTOS
            }
        }

        liquidationTransactionListDTO.pagination = PaginationParser.parse(result)
    }
}
