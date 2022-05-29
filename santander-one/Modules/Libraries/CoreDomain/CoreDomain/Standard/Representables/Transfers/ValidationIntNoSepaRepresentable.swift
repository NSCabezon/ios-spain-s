//
//  ValidationIntNoSepaRepresentable.swift
//  CoreDomain
//
//  Created by Juan Diego Vázquez Moreno on 25/1/22.
//

public protocol ValidationIntNoSepaRepresentable {
    var settlementAmountPayerRepresentable: AmountRepresentable? { get }
    var settlementAmountBenefRepresentable: AmountRepresentable? { get }
    var refAcelera: String? { get }
    var tipoCambioPrecisoRepresentable: AmountRepresentable? { get }
    var impTotComCompRepresentable: AmountRepresentable? { get }
    var impTotComBenefActRepresentable: AmountRepresentable? { get }
    var impCargoContravalRepresentable: AmountRepresentable? { get }
    var impNominalOperacionRepresentable: AmountRepresentable? { get }
    var impConcepLiqCompRepresentable: AmountRepresentable? { get }
    var swiftExpensesRepresentable: ValidationNoSepaSettlementRepresentable? { get }
    var mailExpensesRepresentable: ValidationNoSepaSettlementRepresentable? { get }
    var expensesRepresentable: ValidationNoSepaSettlementRepresentable? { get }
    var valueDate: Date? { get }
    var scaRepresentable: SCARepresentable? { get }
    var token: String? { get }
    var benefActingRepresentable: IdIssuerPayeeRepresentable? { get }
    var financialAgentActingRepresentable: IdIssuerPayeeRepresentable? { get }
}
