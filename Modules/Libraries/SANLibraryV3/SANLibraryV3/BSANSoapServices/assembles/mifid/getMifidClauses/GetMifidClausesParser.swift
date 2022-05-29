import Fuzi
public class GetMifidClausesParser: BSANParser<GetMifidClausesResponse,GetMifidClausesHandler> {
    override func setResponseData() {
        response.mifidDTO = handler.mifidDTO
    }
}

public class GetMifidClausesHandler: BSANHandler {
    var mifidDTO = MifidDTO()
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "listaClausulas":
            mifidDTO.clauseModelList = [MifidClauseDTO]()
            for clausula in element.css("clausulas"){
                var mifidClauseDTO = MifidClauseDTO()
                if let clausulaProduct = clausula.firstChild(css: "clausulaProducto"),
                    let codNode = clausulaProduct.firstChild(css: "COD_ALFANUM_6") {
                    mifidClauseDTO.code = codNode.stringValue
                }
                mifidClauseDTO.clauseText = ""
                for node in clausula.children {
                    if let tag = node.tag, tag.starts(with: "textoClausulaLinea"){
                        mifidClauseDTO.clauseText?.append(node.stringValue)
                        mifidClauseDTO.clauseText?.append(" ")
                    }
                }
                mifidDTO.clauseModelList?.append(mifidClauseDTO)
            }
            
        case "info":
            break
        case "clausulasAsesoramiento":
            var mifidAdviceDTO = MifidAdviceDTO()
            if let result = element.firstChild(css: "resultadoAsesoramiento") {
                mifidAdviceDTO.adviceResultCode = result.stringValue
            }
            
            if let result = element.firstChild(css: "resultadoEvaluacionMIFID") {
                mifidAdviceDTO.mifidEvaluationResultCode = result.stringValue
            }
            
            if let result = element.firstChild(css: "tituloResultadoAsesoramiento") {
                mifidAdviceDTO.adviceTitle = result.stringValue
            }
            
            if let result = element.firstChild(css: "textoResultadoAsesoramiento") {
                mifidAdviceDTO.adviceMessage = result.stringValue
            }

            mifidDTO.mifidAdviceDTO = mifidAdviceDTO
            
        default:
            BSANLogger.e("GetMifidClausesHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
