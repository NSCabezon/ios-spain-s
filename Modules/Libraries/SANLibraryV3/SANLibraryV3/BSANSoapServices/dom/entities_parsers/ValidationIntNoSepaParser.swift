import Fuzi

class ValidationIntNoSepaParser: DTOParser {
    public static func parse(_ node: XMLElement) -> ValidationIntNoSepaDTO {
        var validationIntNoSepaDTO = ValidationIntNoSepaDTO()
        
        if let impLiqOrd = node.firstChild(tag: "impLiqOrd"){
            validationIntNoSepaDTO.settlementAmountPayer = AmountDTOParser.parse(impLiqOrd)
        }
        
        if let refAcelera = node.firstChild(tag: "refAcelera"){
            validationIntNoSepaDTO.refAcelera = refAcelera.stringValue
        }

        if let tipoCambio = node.firstChild(tag: "tipoCambio") {
            validationIntNoSepaDTO.tipoCambioPreciso = AmountDTOParser.parse(tipoCambio)
        }
        
        if let impLiqBenef = node.firstChild(tag: "impLiqBenef"){
            validationIntNoSepaDTO.settlementAmountBenef = AmountDTOParser.parse(impLiqBenef)
        }
        
        if let impTotComComp = node.firstChild(tag: "impTotComComp"){
            validationIntNoSepaDTO.impTotComComp = AmountDTOParser.parse(impTotComComp)
        }
        
        if let impTotComBenefAct = node.firstChild(tag: "impTotComBenefAct"){
            validationIntNoSepaDTO.impTotComBenefAct = AmountDTOParser.parse(impTotComBenefAct)
        }
        
        if let impCargoContraval = node.firstChild(tag: "impCargoContraval"){
            validationIntNoSepaDTO.impCargoContraval = AmountDTOParser.parse(impCargoContraval)
        }
        
        if let impNominalOperacion = node.firstChild(tag: "impNominalOperacion"){
            validationIntNoSepaDTO.impNominalOperacion = AmountDTOParser.parse(impNominalOperacion)
        }
        
        if let impConcepLiqComp = node.firstChild(tag: "impConcepLiqComp") {
            validationIntNoSepaDTO.impConcepLiqComp = AmountDTOParser.parse(impConcepLiqComp)
        }
        
        if let fechaValor = node.firstChild(tag: "fechaValor"){
            validationIntNoSepaDTO.valueDate = DateFormats.safeDate(fechaValor.stringValue)
        }
        
        if let settlements = node.firstChild(tag: "liquidaciones") {
            let children = settlements.children(tag: "dato")
            if let expenses = children.first(where: {
                let value = $0.firstChild(tag: "conceptoLiq")
                return value?.stringValue == "291" ||
                value?.stringValue == "292" ||
                value?.stringValue == "293"
            }) {
                validationIntNoSepaDTO.expenses = ValidationNoSepaSettlementParser.parse(expenses)
            }
            if let swiftExpenses = children.first(where: { $0.firstChild(tag: "conceptoLiq")?.stringValue == "546" }) {
                validationIntNoSepaDTO.swiftExpenses = ValidationNoSepaSettlementParser.parse(swiftExpenses)
            }
            if let mailExpenses = children.first(where: { $0.firstChild(tag: "conceptoLiq")?.stringValue == "549" }) {
                validationIntNoSepaDTO.mailExpenses = ValidationNoSepaSettlementParser.parse(mailExpenses)
            }
        }
        
        validationIntNoSepaDTO.signature = SignatureDTOParser.parse(node)
        
        if let token = node.firstChild(tag: "token") {
            validationIntNoSepaDTO.token = token.stringValue.trim()
        }
        
        if let actuanteBeneficiario = node.firstChild(tag: "actuanteBeneficiario"){
            validationIntNoSepaDTO.benefActing = IdActuantePayeeDTOParser.parse(actuanteBeneficiario)
        }
        
        if let actuanteAgenteFinanciero = node.firstChild(tag: "actuanteAgenteFinanciero"){
            validationIntNoSepaDTO.financialAgentActing = IdActuantePayeeDTOParser.parse(actuanteAgenteFinanciero)
        }
        
        return validationIntNoSepaDTO
    }
}
