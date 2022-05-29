//
//  GetLoanConditionsPdfRequest.swift
//  SANServicesLibrary
//
//  Created by Ali Ghanbari Dolatshahi on 22/12/21.
//

import Foundation
import SANServicesLibrary

struct GetLoanConditionsPdfRequest: SoapBodyConvertible {
    var amount: AmountDTO
    var loanPartialAmortization: LoanPartialAmortizationDTO
    var amortizationType: PartialAmortizationType

    var body: String {
        return """
        <entrada>
            <contrato>
                <CENTRO>
                    <EMPRESA>\(loanPartialAmortization.userContractDTO?.bankCode ?? "")</EMPRESA>
                    <CENTRO>\(loanPartialAmortization.userContractDTO?.branchCode ?? "")</CENTRO>
                </CENTRO>
                <PRODUCTO>\(loanPartialAmortization.userContractDTO?.product ?? "")</PRODUCTO>
                <NUMERO_DE_CONTRATO>\(loanPartialAmortization.userContractDTO?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
            </contrato>
           <fechaValor>\(loanPartialAmortization.fechaValor_FECVAL1 ?? "")</fechaValor>
           <importeAmortizacion>
               <IMPORTE>\(getValueForWS(value: amount.value))</IMPORTE>
               <DIVISA>\(amount.currencyRepresentable?.currencyName ?? "")</DIVISA>
           </importeAmortizacion>
           <secuencialOperacion>\(loanPartialAmortization.numeroSecuOper_HNUOPEM ?? "")</secuencialOperacion>
           <indicadorCuota>\((PartialAmortizationType.decreaseFee == amortizationType) ? "S" : "N")</indicadorCuota>
           <indicadorVencimiento>\((PartialAmortizationType.decreaseTime == amortizationType) ? "S" : "N")</indicadorVencimiento>
        </entrada>
        """
    }

    public func getValueForWS(value: Decimal?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.negativeFormat = "#,##0.00"
        numberFormatter.positiveFormat = "#,##0.00"

        if let value = value {
            return numberFormatter.string(from: value as NSDecimalNumber) ?? ""
        }

        return ""
    }
}
