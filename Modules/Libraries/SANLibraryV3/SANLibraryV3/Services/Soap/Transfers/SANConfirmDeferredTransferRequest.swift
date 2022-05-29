//
//  ConfirmDeferredTransferRequest.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 28/7/21.
//

import CoreDomain
import SANServicesLibrary

public struct SANConfirmDeferredTransferRequest: SoapBodyConvertible {
    let params: SANConfirmDeferredTransferRequestParams
    public var body: String {
        let dateNextExecution: String
        if let date = params.dateNextExecution {
            dateNextExecution = date.stringWithDateFormat("yyyy-MM-dd")
        } else {
            dateNextExecution = ""
        }
        
        return """
            <entrada>
                <nombreCompletoBeneficiario>\(params.beneficiary)</nombreCompletoBeneficiario>
                <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>
                <concepto>\(params.concept ?? "")</concepto>
                <fechaProximaEjecucion>\(dateNextExecution)</fechaProximaEjecucion>
                <divisaCtoOrd>\(params.currency)</divisaCtoOrd>
                <codigoActuante>
                    <TIPO_DE_ACTUANTE>
                        <EMPRESA>\(params.actuanteCompany)</EMPRESA>
                        <COD_TIPO_DE_ACTUANTE>\(params.actuanteCode)</COD_TIPO_DE_ACTUANTE>
                    </TIPO_DE_ACTUANTE>
                    <NUMERO_DE_ACTUANTE>\(params.actuanteNumber)</NUMERO_DE_ACTUANTE>
                </codigoActuante>
                <indicadorAltaPayee>\(params.saveAsUsual ? "S" : "N")</indicadorAltaPayee>
                <alias>\(params.saveAsUsualAlias.uppercased())</alias>
                <token>\(params.dataToken)</token>
                <ticket>\(params.ticketOTP)</ticket>
                <codigoOtp>\(params.codeOTP)</codigoOtp>
            </entrada>
            """
    }
    
    public init(params: SANConfirmDeferredTransferRequestParams) {
        self.params = params
    }
}

public struct SANConfirmDeferredTransferRequestParams {
    public let beneficiary: String
    
    public let indicatorResidence: Bool
    public let concept: String?
    public let dateNextExecution: Date?
    public let currency: String
    
    public let actuanteCompany: String
    public let actuanteCode: String
    public let actuanteNumber: String
    public let saveAsUsual: Bool
    public let saveAsUsualAlias: String
    public let dataToken: String
    public let ticketOTP: String
    public let codeOTP: String
    
    public init(beneficiary: String,
                indicatorResidence: Bool,
                concept: String?,
                dateNextExecution: Date?,
                currency: String,
                actuanteCompany: String,
                actuanteCode: String,
                actuanteNumber: String,
                saveAsUsual: Bool,
                saveAsUsualAlias: String,
                dataToken: String,
                ticketOTP: String,
                codeOTP: String) {
        self.beneficiary = beneficiary
        self.indicatorResidence = indicatorResidence
        self.concept = concept
        self.dateNextExecution = dateNextExecution
        self.currency = currency
        self.actuanteCompany = actuanteCompany
        self.actuanteCode = actuanteCode
        self.actuanteNumber = actuanteNumber
        self.saveAsUsual = saveAsUsual
        self.saveAsUsualAlias = saveAsUsualAlias
        self.dataToken = dataToken
        self.ticketOTP = ticketOTP
        self.codeOTP = codeOTP
    }
}
