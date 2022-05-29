import Fuzi

public class GetClausesPensionMifidParser: BSANParser<GetClausesPensionMifidResponse, GetClausesPensionMifidHandler> {
    override func setResponseData() {
        response.pensionMifidDTO = handler.pensionMifidDTO
    }
}

public class GetClausesPensionMifidHandler: BSANHandler {
    var pensionMifidDTO = PensionMifidDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
            
        case "resultadoAsesoramiento":
            pensionMifidDTO.adviceResultCode = element.stringValue.trim()
            
        case "resultadoEvaluacionMIFID":
            pensionMifidDTO.mifidEvaluationResultCode = element.stringValue.trim()
            
        case "tituloResultadoAsesoramiento":
            pensionMifidDTO.adviceTitle = element.stringValue.trim()
            
        case "textoResultadoAsesoramiento":
            pensionMifidDTO.adviceMessage = element.stringValue.trim()
            break
            
        case "descripcionAccion":
            pensionMifidDTO.actionDescription = element.stringValue.trim()
            
        case "accionMifid":
            pensionMifidDTO.mifidAction = InstructionStatusDTOParser.parse(element)
            
        case "descClausulaVar":
            pensionMifidDTO.varClauseDesc = element.stringValue.trim()
            
        case "descClausulaObl":
            pensionMifidDTO.OblClauseDesc = element.stringValue.trim()
            
        case "listaClausulasMifid":
            var list = [PensionMifidClauseDTO]()
            
            for clausulaMifid in element.children {
                var clause = PensionMifidClauseDTO()
                var text = ""
                
                for node in clausulaMifid.children {
                    if let nodeTag = node.tag {
                        switch nodeTag {
                        case "tipoExpediente":
                            var tipo = FileTypeDTO()
                            
                            if let MIF_TIPO_EXPEDIENTE = node.firstChild(css: "MIF_TIPO_EXPEDIENTE"){
                                tipo.fileTypeMifid = InstructionStatusDTOParser.parse(MIF_TIPO_EXPEDIENTE)
                            }
                            
                            if let CEXPEDTE_SECUENCIAL_MEDIO = node.firstChild(css: "CEXPEDTE_SECUENCIAL_MEDIO"){
                                tipo.fileSequenceCode = CEXPEDTE_SECUENCIAL_MEDIO.stringValue.trim()
                            }
                            clause.fileTypeDTO = tipo
                            
                        case "tipoClausula":
                            clause.clauseType = InstructionStatusDTOParser.parse(node)
                            
                        case "clausulaProd":
                            clause.prodClause = InstructionStatusDTOParser.parse(node)
                            
                        default:
                            if node.tag?.starts(with: "textoClausula") == true  {
                                let trimmedValue = node.stringValue.trim()
                                text += " " + trimmedValue
                            }
                        }
                    }
                }
                clause.clauseDesc = text.trim()
                list.append(clause)
            }
            
            pensionMifidDTO.pensionMifidClauseDTOS = list
        default:
            BSANLogger.e("GetClausesPensionMifidHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
