import Fuzi

public class GetCounterValueDetailParser: BSANParser<GetCounterValueDetailResponse, GetCounterValueDetailHandler> {
    override func setResponseData() {
        response.rmvDetailDTO = handler.rmvDetailDTO
    }
}

public class GetCounterValueDetailHandler: BSANHandler {
    var rmvDetailDTO = RMVDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "listaDetalleSaldo":
            for node in element.children(staticTag: "detalleSaldo") {
                var detail = RMVLineDetailDTO()
                
                if let importeCotizacion = node.firstChild(css: "importeCotizacion") {
                    detail.priceAmount = AmountDTOParser.parse(importeCotizacion)
                }
                
                if let numTitulos = node.firstChild(css: "numTitulos") {
                    detail.sharesCount = DTOParser.safeDecimal(numTitulos.stringValue.trim())
                }
                
                if let descColumnaSaldo = node.firstChild(css: "descColumnaSaldo") {
                    detail.columnDesc = descColumnaSaldo.stringValue.trim()
                }
                
                if let importeValoracion = node.firstChild(css: "importeValoracion") {
                    detail.valueAmount = AmountDTOParser.parse(importeValoracion)
                }
                
                if let fechaCotizacion = node.firstChild(css: "fechaCotizacion") {
                    detail.priceDate = fechaCotizacion.stringValue.trim()
                }
                
                rmvDetailDTO.rmvLineDetailModelList.append(detail)
            }
        case "info":
            break
        case "descValor":
            rmvDetailDTO.stockDesc = element.stringValue.trim()
        default:
            BSANLogger.e("GetCounterValueDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
