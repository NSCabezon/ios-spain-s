import Foundation
import Fuzi

class InsuranceDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> InsuranceDTO {
        
        var insuranceDTO = InsuranceDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "contratoPartenon":
                    insuranceDTO.contract = ContractDTOParser.parse(element)
                    break
                case "subtipoProd":
                    insuranceDTO.productSubtypeDTO = ProductSubtypeDTOParser.parse(element)
                    break
                case "fecSituacionCto":
                    insuranceDTO.fecSituacionCto = DateFormats.safeDate(element.stringValue)
                    break
                case "indVisibleAlias":
                    insuranceDTO.indVisibleAlias = safeBoolean(element.stringValue)
                    break
                case "codCesta":
                    insuranceDTO.codCesta = InstructionStatusDTOParser.parse(element)
                    break
                case "codFamiliaProd":
                    insuranceDTO.codFamiliaProd = InstructionStatusDTOParser.parse(element)
                    break
                case "indActivoPasivo":
                    insuranceDTO.indActivoPasivo = element.stringValue.trim()
                    break
                case "tipoOperativa":
                    insuranceDTO.tipoOperativa = element.stringValue.trim()
                    break
                case "indError":
                    insuranceDTO.indError = safeBoolean(element.stringValue)
                    break
                case "descripProd":
                    insuranceDTO.contractDescription = element.stringValue.trim()
                    break
                case "tipoSituacionCto":
                    insuranceDTO.tipoSituacionCto = element.stringValue.trim()
                    break
                case "titular":
                    insuranceDTO.cliente = ClientDTOParser.parse(element)
                    break
                case "tipoInterv":
                    insuranceDTO.ownershipType = element.stringValue.trim()
                    break
                case "descTipoInterv":
                    insuranceDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: element.stringValue.trim())
                    break
                case "importeSaldoActual":
                    insuranceDTO.importeSaldoActual = AmountDTOParser.parse(element)
                    break
                case "idPoliza":
                    insuranceDTO.idPoliza = InsurancePolicyDTOParser.parse(element)
                    break;
                case "cliente2":
                    insuranceDTO.cliente2 = ClientDTOParser.parse(element)
                    break;
                case "descIdPoliza":
                    insuranceDTO.descIdPoliza = element.stringValue.trim()
                    break
                case "fechaEfecto":
                    insuranceDTO.fechaEfecto = DateFormats.safeDate(element.stringValue)
                    break
                case "codigoFamSgu":
                    insuranceDTO.codigoFamSgu = element.stringValue.trim()
                    break
                case "subCodFamSgu":
                    insuranceDTO.subCodFamSgu = element.stringValue.trim()
                    break
                case "referenciaExterna":
                    insuranceDTO.referenciaExterna = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("InsuranceDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return insuranceDTO
    }
}
