import Foundation
import Fuzi

class InstructionStatusDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> InstructionStatusDTO {
        var instructionStatusDTO = InstructionStatusDTO()
        instructionStatusDTO.company = node.firstChild(tag:"EMPRESA")?.stringValue.trim()
        
        if let codAlfanum = node.firstChild(tag:"COD_ALFANUM")?.stringValue.trim() {
            instructionStatusDTO.alphanumericCode = codAlfanum
        } else if let codigoAlfanum = node.firstChild(tag:"CODIGO_ALFANUM")?.stringValue.trim() {
            instructionStatusDTO.alphanumericCode = codigoAlfanum
        } else if let codAlfanum = node.firstChild(tag:"CODIGO_ALFANUM_3")?.stringValue.trim() {
            instructionStatusDTO.alphanumericCode = codAlfanum
        } else if let codAlfanum = node.firstChild(tag:"COD_ALFANUM_6")?.stringValue.trim() {
            instructionStatusDTO.alphanumericCode = codAlfanum
        } else if let codTipoActuante = node.firstChild(tag: "COD_TIPO_DE_ACTUANTE")?.stringValue.trim() {
            instructionStatusDTO.alphanumericCode = codTipoActuante
        }
        return instructionStatusDTO
    }
}
