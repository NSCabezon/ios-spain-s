//
//  GetLoanPartialAmortizationRequest.swift
//  SANServicesLibrary
//
//  Created by Andres Aguirre Juarez on 19/10/21.
//

import Foundation
import SANServicesLibrary

struct GetLoanPartialAmortizationRequest: SoapBodyConvertible {
    let loan: LoanDTO
    
    var body: String {
     return """
        <prestamo>
            <contrato>
                <CENTRO>
                    <EMPRESA>\(loan.contract?.bankCode ?? "")</EMPRESA>
                    <CENTRO>\(loan.contract?.branchCode ?? "")</CENTRO>
                </CENTRO>
                <PRODUCTO>\(loan.contract?.product ?? "")</PRODUCTO>
                <NUMERO_DE_CONTRATO>\(loan.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
            </contrato>
        </prestamo>
        """
    }
}
