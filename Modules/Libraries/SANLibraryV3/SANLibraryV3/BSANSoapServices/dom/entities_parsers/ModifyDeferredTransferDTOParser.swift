import Fuzi

class ModifyDeferredTransferDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> ModifyDeferredTransferDTO {
        var modifyDeferredTransferDTO = ModifyDeferredTransferDTO()
        
        modifyDeferredTransferDTO.signatureDTO = SignatureDTOParser.parse(node)
        
        if let tipoSEPA = node.firstChild(tag: "tipoSEPA"){
            modifyDeferredTransferDTO.sepaType = tipoSEPA.stringValue.trim()
        }
        
        if let nombrePrimerTitular = node.firstChild(tag: "nombrePrimerTitular"){
            modifyDeferredTransferDTO.nameFirstHolder = nombrePrimerTitular.stringValue.trim()
        }
        
        if let tokenPasos = node.firstChild(tag: "tokenPasos"){
            modifyDeferredTransferDTO.dataToken = tokenPasos.stringValue.trim()
        }
        
        if let nombreCompletoBeneficiario = node.firstChild(tag: "nombreCompletoBeneficiario"){
            modifyDeferredTransferDTO.fullNameBeneficiary = nombreCompletoBeneficiario.stringValue.trim()
        }
        
        if let actuanteType = node.firstChild(tag: "actuanteBeneficiario") {
            if let numActuante = actuanteType.firstChild(tag: "NUMERO_DE_ACTUANTE"){
                modifyDeferredTransferDTO.actingNumber = numActuante.stringValue.trim()
            }
            
            if let tipoActuante = actuanteType.firstChild(tag: "TIPO_DE_ACTUANTE"){
                modifyDeferredTransferDTO.actingBeneficiary = InstructionStatusDTOParser.parse(tipoActuante)
            }
        }
        
        if let naturalezaPago = node.firstChild(tag: "tipoOperacion"){
            if let operatioType = naturalezaPago.firstChild(tag: "NATURALEZA_PAGO_MISPAG"){
                modifyDeferredTransferDTO.operationType = InstructionStatusDTOParser.parse(operatioType)
            }
            
            if let indTipOperation = naturalezaPago.firstChild(tag: "IND_TIP_OPERACION"){
                modifyDeferredTransferDTO.indOperationType = indTipOperation.stringValue.trim()
            }
        }
        
        if let nextExecutionDate = node.firstChild(tag: "fechaProximaEjecucion"){
            modifyDeferredTransferDTO.nextExecutionDate = DateFormats.safeDate(nextExecutionDate.stringValue)
        }
        
        if let amount = node.firstChild(tag: "importe"){
            modifyDeferredTransferDTO.amountDTO = AmountDTOParser.parse(amount)
        }
        
        if let concepto = node.firstChild(tag: "concepto"){
            modifyDeferredTransferDTO.concept = concepto.stringValue.trim()
        }
        
        if let indicadorResidenciaDestinatario = node.firstChild(tag: "indicadorResidenciaDestinatario"){
            modifyDeferredTransferDTO.residenceIndicator = safeBoolean(indicadorResidenciaDestinatario.stringValue.trim())
        }
        
        if let cuentaIBANBeneficiario = node.firstChild(tag: "cuentaIBANBeneficiario"){
            modifyDeferredTransferDTO.beneficiaryIBAN = IBANDTOParser.parse(cuentaIBANBeneficiario)
        }
    
        return modifyDeferredTransferDTO
    }
}
