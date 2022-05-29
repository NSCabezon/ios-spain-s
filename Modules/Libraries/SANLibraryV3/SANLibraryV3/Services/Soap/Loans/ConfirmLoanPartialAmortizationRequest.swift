//
//  LoanRequest.swift
//  SANServicesLibrary
//
//  Created by Andres Aguirre Juarez on 13/10/21.
//

import Foundation
import SANServicesLibrary

struct ConfirmLoanPartialAmortizationRequest: SoapBodyConvertible {
    let loanPartialAmortization: LoanPartialAmortizationDTO
    let amortizationType: PartialAmortizationType
    let loanValidation: LoanValidationDTO
    let signature: SignatureDTO
    let amount: AmountDTO
    
    func getSignatureXmlFormatP(signatureDTO: SignatureDTO) -> String {
        var xml = ""
        if let positions = signatureDTO.positions, positions.count > 0,
           let values = signatureDTO.values, values.count > 0 {
            for i in 0...positions.count - 1 {
                xml += "<p\(positions[i])>\(values[i])</p\(positions[i])>"
            }
        }
        return xml
    }
    
    var body: String {
        return """
                   <entrada>
                      <firma>\(getSignatureXmlFormatP(signatureDTO: signature))</firma>
                      <importeAmortizar>
                          <IMPORTE>\(amount.value ?? 0.0)</IMPORTE>
                          <DIVISA>\(amount.currency?.currencyName ?? "")</DIVISA>
                      </importeAmortizar>
                      <indAmortizarCuota>\((PartialAmortizationType.decreaseFee == amortizationType) ? "S" : "N")</indAmortizarCuota>
                      <indAmortizarVencimiento>\((PartialAmortizationType.decreaseTime == amortizationType) ? "S" : "N")</indAmortizarVencimiento>
                      <dataToken>\(loanValidation.token ?? "")</dataToken>
                   </entrada>
                   <amortizacionParcial>
                       <prestamo>
                           <CENTRO>
                               <EMPRESA>\(loanPartialAmortization.loanContractDTO?.bankCode ?? "")</EMPRESA>
                               <CENTRO>\(loanPartialAmortization.loanContractDTO?.branchCode ?? "")</CENTRO>
                           </CENTRO>
                           <PRODUCTO>\(loanPartialAmortization.loanContractDTO?.product ?? "")</PRODUCTO>
                           <NUMERO_DE_CONTRATO>\(loanPartialAmortization.loanContractDTO?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                       </prestamo>
                       <contrato>
                           <CENTRO>
                               <EMPRESA>\(loanPartialAmortization.userContractDTO?.bankCode ?? "")</EMPRESA>
                               <CENTRO>\(loanPartialAmortization.userContractDTO?.branchCode ?? "")</CENTRO>
                           </CENTRO>
                           <PRODUCTO>\(loanPartialAmortization.userContractDTO?.product ?? "")</PRODUCTO>
                           <NUMERO_DE_CONTRATO>\(loanPartialAmortization.userContractDTO?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                       </contrato>
                       <cuentaAsociada>
                           <CENTRO>
                               <EMPRESA>\(loanPartialAmortization.linkedAccountContractDTO?.bankCode ?? "")</EMPRESA>
                               <CENTRO>\(loanPartialAmortization.linkedAccountContractDTO?.branchCode ?? "")</CENTRO>
                           </CENTRO>
                           <PRODUCTO>\(loanPartialAmortization.linkedAccountContractDTO?.product ?? "")</PRODUCTO>
                           <NUMERO_DE_CONTRATO>\(loanPartialAmortization.linkedAccountContractDTO?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                       </cuentaAsociada>
                       <cuentaAsociada_int>
                           <CENTRO>
                               <EMPRESA>\(loanPartialAmortization.linkedAccountIntContractDTO?.bankCode ?? "")</EMPRESA>
                               <CENTRO>\(loanPartialAmortization.linkedAccountIntContractDTO?.branchCode ?? "")</CENTRO>
                           </CENTRO>
                           <PRODUCTO>\(loanPartialAmortization.linkedAccountIntContractDTO?.product ?? "")</PRODUCTO>
                           <NUMERO_DE_CONTRATO>\(loanPartialAmortization.linkedAccountIntContractDTO?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                       </cuentaAsociada_int>
                       <numeroSecuOper_HNUOPEM>\(loanPartialAmortization.numeroSecuOper_HNUOPEM ?? "")</numeroSecuOper_HNUOPEM>
                       <codProductoContrato_IDPROD>\(loanPartialAmortization.codProductoContrato_IDPROD ?? "")</codProductoContrato_IDPROD>
                       <codSubtipoProducto_CODSPROD>\(loanPartialAmortization.codSubtipoProducto_CODSPROD ?? "")</codSubtipoProducto_CODSPROD>
                       <origenOrdenMarcajDecreto_IDORIGEN>\(loanPartialAmortization.origenOrdenMarcajDecreto_IDORIGEN ?? "")</origenOrdenMarcajDecreto_IDORIGEN>
                       <indDevolEfectDEspAcept_INDACTE1>\(loanPartialAmortization.indDevolEfectDEspAcept_INDACTE1 ?? "")</indDevolEfectDEspAcept_INDACTE1>
                       <indDuplicado_INDDUP>\(loanPartialAmortization.indDuplicado_INDDUP ?? "")</indDuplicado_INDDUP>
                       <indIntermediacion_INDINTER>\(loanPartialAmortization.indIntermediacion_INDINTER ?? "")</indIntermediacion_INDINTER>
                       <indNoAmortizaPeriodCaren_INDNAMCA>\(loanPartialAmortization.indNoAmortizaPeriodCaren_INDNAMCA ?? "")</indNoAmortizaPeriodCaren_INDNAMCA>
                       <indPrestamoConsu_INDPTCON>\(loanPartialAmortization.indPrestamoConsu_INDPTCON ?? "")</indPrestamoConsu_INDPTCON>
                       <indPrestamoLeasing_INDPTLEA>\(loanPartialAmortization.indPrestamoLeasing_INDPTLEA ?? "")</indPrestamoLeasing_INDPTLEA>
                       <indResidente_INREN>\(loanPartialAmortization.indResidente_INREN ?? "")</indResidente_INREN>
                       <indGrupo_INDGRU>\(loanPartialAmortization.indGrupo_INDGRU ?? "")</indGrupo_INDGRU>
                       <indOrigenDestino_IORIDES>\(loanPartialAmortization.indOrigenDestino_IORIDES ?? "")</indOrigenDestino_IORIDES>
                       <fechaVencimiento_FECVENC2>\(loanPartialAmortization.fechaVencimiento_FECVENC2 ?? "")</fechaVencimiento_FECVENC2>
                       <fechaValor_FECVAL1>\(loanPartialAmortization.fechaValor_FECVAL1 ?? "")</fechaValor_FECVAL1>
                       <importeResidualLeasing_IMPDIVS4>
                           <IMPORTE>\(loanPartialAmortization.importeResidualLeasing_IMPDIVS4?.value ?? 0.0)</IMPORTE>
                           <DIVISA>\(loanPartialAmortization.importeResidualLeasing_IMPDIVS4?.currencyRepresentable?.currencyName ?? "")</DIVISA>
                       </importeResidualLeasing_IMPDIVS4>
                       <importeResidFinal_IMPDIVS5>
                           <IMPORTE>\(loanPartialAmortization.importeResidFinal_IMPDIVS5?.value ?? 0.0)</IMPORTE>
                           <DIVISA>\(loanPartialAmortization.importeResidFinal_IMPDIVS5?.currencyRepresentable?.currencyName ?? "")</DIVISA>
                       </importeResidFinal_IMPDIVS5>
                       <importeLimiteInicial_IMPDIVS1>
                           <IMPORTE>\(loanPartialAmortization.importeLimiteInicial_IMPDIVS1?.value ?? 0.0)</IMPORTE>
                           <DIVISA>\(loanPartialAmortization.importeLimiteInicial_IMPDIVS1?.currencyRepresentable?.currencyName ?? "")</DIVISA>
                       </importeLimiteInicial_IMPDIVS1>
                       <importeLimiteActual_IMPDIVS2>
                           <IMPORTE>\(loanPartialAmortization.importeLimiteActual_IMPDIVS2?.value ?? 0.0)</IMPORTE>
                           <DIVISA>\(loanPartialAmortization.importeLimiteActual_IMPDIVS2?.currencyRepresentable?.currencyName ?? "")</DIVISA>
                       </importeLimiteActual_IMPDIVS2>
                       <nombreMoneda_NOMMONCO>\(loanPartialAmortization.nombreMoneda_NOMMONCO?.trim() ?? "")</nombreMoneda_NOMMONCO>
                       <codTecnicoAplicacion_APLICACI>\(loanPartialAmortization.codTecnicoAplicacion_APLICACI ?? "")</codTecnicoAplicacion_APLICACI>
                       <tipoObjetoOper_ATIPOB>\(loanPartialAmortization.tipoObjetoOper_ATIPOB ?? "")</tipoObjetoOper_ATIPOB>
                       <tipoObjeto_BTIPOB>\(loanPartialAmortization.tipoObjeto_BTIPOB ?? "")</tipoObjeto_BTIPOB>
                       <codOperaBasica_CODOPBAS>\(loanPartialAmortization.codOperaBasica_CODOPBAS ?? "")</codOperaBasica_CODOPBAS>
                       <campo1JerarquiaParticulari_EHIDOBJ1>\(loanPartialAmortization.campo1JerarquiaParticulari_EHIDOBJ1?.trim() ?? "")</campo1JerarquiaParticulari_EHIDOBJ1>
                       <campo2JerarquiaParticulari_EHIDOBJ2>\(loanPartialAmortization.campo2JerarquiaParticulari_EHIDOBJ2?.trim() ?? "")</campo2JerarquiaParticulari_EHIDOBJ2>
                       <codEstandarReferencia_COESTREF>\(loanPartialAmortization.codEstandarReferencia_COESTREF ?? "")</codEstandarReferencia_COESTREF>
                       <numero>\(loanPartialAmortization.numero ?? "")</numero>
                       <tipo_EHTIPOB>\(loanPartialAmortization.tipo_EHTIPOB ?? "")</tipo_EHTIPOB>
                   </amortizacionParcial>
                   """
    }
}
