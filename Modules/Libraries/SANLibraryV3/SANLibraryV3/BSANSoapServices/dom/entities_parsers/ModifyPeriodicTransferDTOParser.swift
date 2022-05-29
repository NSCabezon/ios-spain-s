import Fuzi

class ModifyPeriodicTransferDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> ModifyPeriodicTransferDTO {
        var modifyPeriodicTransferDTO = ModifyPeriodicTransferDTO()
        
        modifyPeriodicTransferDTO.signatureDTO = SignatureDTOParser.parse(node)
        
        if let tipoSEPA = node.firstChild(tag: "tipoSEPA"){
            modifyPeriodicTransferDTO.sepaType = tipoSEPA.stringValue.trim()
        }
        
        if let nombrePrimerTitular = node.firstChild(tag: "nombrePrimerTitular"){
            modifyPeriodicTransferDTO.nameFirstHolder = nombrePrimerTitular.stringValue.trim()
        }
        
        if let tokenPasos = node.firstChild(tag: "tokenPasos"){
            modifyPeriodicTransferDTO.dataToken = tokenPasos.stringValue.trim()
        }
        
        if let nombreCompletoBeneficiario = node.firstChild(tag: "nombreCompletoBeneficiario"){
            modifyPeriodicTransferDTO.fullNameBeneficiary = nombreCompletoBeneficiario.stringValue.trim()
        }
        
        if let actuanteBeneficiario = node.firstChild(tag: "actuanteBeneficiario"){
            if let numActuante = actuanteBeneficiario.firstChild(tag: "NUMERO_DE_ACTUANTE"){
                modifyPeriodicTransferDTO.actingNumber = numActuante.stringValue.trim()
            }
            
            if let tipoActuante = actuanteBeneficiario.firstChild(tag: "TIPO_DE_ACTUANTE"){
                modifyPeriodicTransferDTO.actingBeneficiary = InstructionStatusDTOParser.parse(tipoActuante)
            }
        }
        
        if let nextExecutionDate = node.firstChild(tag: "fechaProximaEjecucion"){
            modifyPeriodicTransferDTO.nextExecutionDate = DateFormats.safeDate(nextExecutionDate.stringValue)
        }
        
        if let amount = node.firstChild(tag: "importe"){
            modifyPeriodicTransferDTO.amountDTO = AmountDTOParser.parse(amount)
        }
        
        if let concepto = node.firstChild(tag: "concepto"){
            modifyPeriodicTransferDTO.concept = concepto.stringValue.trim()
        }
        
        if let indicadorResidenciaDestinatario = node.firstChild(tag: "indicadorResidenciaDestinatario"){
            modifyPeriodicTransferDTO.residenceIndicator = safeBoolean(indicadorResidenciaDestinatario.stringValue.trim())
        }
        
        if let cuentaIBANBeneficiario = node.firstChild(tag: "cuentaIBANBeneficiario"){
            modifyPeriodicTransferDTO.beneficiaryIBAN = IBANDTOParser.parse(cuentaIBANBeneficiario)
        }
        
        if let tipoOperacion = node.firstChild(tag: "tipoOperacion"){
            if let operatioType = tipoOperacion.firstChild(tag: "NATURALEZA_PAGO_MISPAG"){
                modifyPeriodicTransferDTO.naturalezaPago = InstructionStatusDTOParser.parse(operatioType)
            }
            
            if let indTipOperation = tipoOperacion.firstChild(tag: "IND_TIP_OPERACION"){
                modifyPeriodicTransferDTO.indOperationType = indTipOperation.stringValue.trim()
            }
        }
        
        if let dateStartValidity = node.firstChild(tag: "fechaInicioVigencia"){
            modifyPeriodicTransferDTO.dateStartValidity = DateFormats.safeDate(dateStartValidity.stringValue)
        }
        
        if let dateEndValidity = node.firstChild(tag: "fechaFinVigencia"){
            modifyPeriodicTransferDTO.dateEndValidity = DateFormats.safeDate(dateEndValidity.stringValue)
        }
        
        if let dateIndicator = node.firstChild(tag: "indicadorTratamientoFechaEmis"){
            modifyPeriodicTransferDTO.dateIndicator = InstructionStatusDTOParser.parse(dateIndicator)
        }
        
        if let periodicityIndicator = node.firstChild(tag: "indicadorPeriodicidad"){
            modifyPeriodicTransferDTO.periodicityIndicator = InstructionStatusDTOParser.parse(periodicityIndicator)
        }
        
        if let periodicidad = node.firstChild(tag: "periodicidad"){
            if let tiempo = periodicidad.firstChild(tag: "tiempo"){
                modifyPeriodicTransferDTO.periodicityTime = tiempo.stringValue.trim()
            }
        }
        
        
        return modifyPeriodicTransferDTO
    }
}
