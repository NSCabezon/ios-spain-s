import CoreDomain

public struct ValidationIntNoSepaDTO: Codable {
    public var settlementAmountPayer: AmountDTO?
    public var settlementAmountBenef: AmountDTO?
    public var refAcelera: String?
    public var tipoCambioPreciso: AmountDTO?
    public var impTotComComp: AmountDTO?
    public var impTotComBenefAct: AmountDTO?
    public var impCargoContraval: AmountDTO?
    public var impNominalOperacion: AmountDTO?
    public var impConcepLiqComp: AmountDTO?
    public var swiftExpenses: ValidationNoSepaSettlementDTO?
    public var mailExpenses: ValidationNoSepaSettlementDTO?
    public var expenses: ValidationNoSepaSettlementDTO?
    public var valueDate: Date?
    public var signature: SignatureDTO?
    public var token: String?
    public var benefActing: IdActuantePayeeDTO?
    public var financialAgentActing: IdActuantePayeeDTO?

    public init() {}
}

extension ValidationIntNoSepaDTO: ValidationIntNoSepaRepresentable {

    public var settlementAmountPayerRepresentable: AmountRepresentable? {
        return settlementAmountPayer
    }

    public var settlementAmountBenefRepresentable: AmountRepresentable? {
        return settlementAmountBenef
    }

    public var tipoCambioPrecisoRepresentable: AmountRepresentable? {
        return tipoCambioPreciso
    }

    public var impTotComCompRepresentable: AmountRepresentable? {
        return impTotComComp
    }

    public var impTotComBenefActRepresentable: AmountRepresentable? {
        return impTotComBenefAct
    }

    public var impCargoContravalRepresentable: AmountRepresentable? {
        return impCargoContraval
    }

    public var impNominalOperacionRepresentable: AmountRepresentable? {
        return impNominalOperacion
    }

    public var impConcepLiqCompRepresentable: AmountRepresentable? {
        return impConcepLiqComp
    }

    public var swiftExpensesRepresentable: ValidationNoSepaSettlementRepresentable? {
        return swiftExpenses
    }

    public var mailExpensesRepresentable: ValidationNoSepaSettlementRepresentable? {
        return mailExpenses
    }

    public var expensesRepresentable: ValidationNoSepaSettlementRepresentable? {
        return expenses
    }

    public var scaRepresentable: SCARepresentable? {
        return signature
    }

    public var benefActingRepresentable: IdIssuerPayeeRepresentable? {
        return benefActing
    }

    public var financialAgentActingRepresentable: IdIssuerPayeeRepresentable? {
        return financialAgentActing
    }
}
