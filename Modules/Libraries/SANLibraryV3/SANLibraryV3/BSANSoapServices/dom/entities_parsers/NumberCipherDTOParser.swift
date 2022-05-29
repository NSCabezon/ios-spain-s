import Foundation
import Fuzi

class NumberCipherDTOParser: DTOParser {
    
    public static  func parse(_ node: XMLElement) -> NumberCipherDTO {
        var numberCipher = NumberCipherDTO()
        
        if let numPINCifrado = node.firstChild(tag: "numPINCifrado") {
            numberCipher.numCipher = numPINCifrado.stringValue.trim()
        } else if let numCVV2Cifrado = node.firstChild(tag: "numCVV2RCifrado") {
            numberCipher.numCipher = numCVV2Cifrado.stringValue.trim()
        } else if let numCVV2Cifrado = node.firstChild(tag: "numCVV2Cifrado") {
            numberCipher.numCipher = numCVV2Cifrado.stringValue.trim()
        }
        
        return numberCipher
    }
}
