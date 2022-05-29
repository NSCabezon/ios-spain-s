import Foundation
import Fuzi

class ReposDatosTarjetaParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ReposDatosTarjeta {
        
        let reposDatosTarjeta = ReposDatosTarjeta()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "contratoTarjeta":
                    reposDatosTarjeta.contratoTarjeta = ContractDTOParser.parse(element)
                    break
                case "codigoAplicacion":
                    reposDatosTarjeta.codigoAplicacion = element.stringValue.trim()
                    break
                case "tipoIntervencion":
                    reposDatosTarjeta.tipoIntervencion = element.stringValue.trim()
                    break
                case "numBeneficiario":
                    reposDatosTarjeta.numBeneficiario = element.stringValue.trim()
                    break
                case "numBenefTarjeta":
                    reposDatosTarjeta.numBenefTarjeta = element.stringValue.trim()
                    break
                case "finLista":
                    reposDatosTarjeta.finLista = safeBoolean(element.stringValue)
                    break
                default:
                    BSANLogger.e("ReposDatosTarjetaParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return reposDatosTarjeta
    }
}
