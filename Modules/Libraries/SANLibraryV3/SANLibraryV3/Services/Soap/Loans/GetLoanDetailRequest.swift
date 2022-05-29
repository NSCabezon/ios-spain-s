//
//  GetLoanDetailRequest.swift
//  SANServicesLibrary
//
//  Created by Andres Aguirre Juarez on 19/10/21.
//

import Foundation
import SANServicesLibrary

struct GetLoanDetailRequest: SoapBodyConvertible {
    var loan: LoanDTO
    
    var body: String {
            return """
                       <entrada>
                           <contrato>
                               <CENTRO>
                                   <EMPRESA>\(loan.contractRepresentable?.bankCode ?? "")</EMPRESA>
                                   <CENTRO>\(loan.contractRepresentable?.branchCode ?? "")</CENTRO>
                               </CENTRO>
                               <PRODUCTO>\(loan.contractRepresentable?.product ?? "")</PRODUCTO>
                               <NUMERO_DE_CONTRATO>\(loan.contractRepresentable?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                           </contrato>
                       </entrada>
                    """
    }
}
