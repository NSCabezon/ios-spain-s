//

import Foundation

public class ValidationSwiftRequest: BSANSoapRequest<ValidationSwiftRequestParams, ValidationSwiftHandler, ValidationSwiftResponse, ValidationSwiftParse> {
    
    private static let SERVICE_NAME = "validaSwiftEmision_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Emisioninter_la/F_trasan_emisioninter_la/"
    }
    
    public override var serviceName: String {
        return ValidationSwiftRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let typeTransfer: String
        if let type = params.noSepaTransferInput.type {
            typeTransfer = type.getType()
        } else {
            typeTransfer = "N"
        }
        
        let dateOperation: String
        if let date = params.noSepaTransferInput.dateOperation?.date {
            dateOperation = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateOperation = ""
        }
        
        let accountDestination = params.noSepaTransferInput.beneficiaryAccount.account34
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "        <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <cabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>" +
            "               </cabecera>" +
            "               <datosConexion>\(params.userDataDTO.clientAndChannelXml)</datosConexion>" +
            "               <entrada>" +
            "                   <nombreBeneficiario>\(params.noSepaTransferInput.beneficiary)</nombreBeneficiario>" +
            "                   <cuentaBeneficiario>\(accountDestination)</cuentaBeneficiario>" +
            "                   <indicadorResidencia>\(params.noSepaTransferInput.indicatorResidence ? "S" : "N")</indicadorResidencia>" +
            "                   <fechaOperacion>\(dateOperation)</fechaOperacion>" +
            "                   <pais>\(params.noSepaTransferInput.countryCode)</pais>" +
            "                   <importeOperacion>" +
            "                       <IMPORTE>\(AmountFormats.getValueForWS(value: params.noSepaTransferInput.transferAmount.value))</IMPORTE>" +
            "                       <DIVISA>\(params.noSepaTransferInput.transferAmount.currency?.currencyName  ?? "")</DIVISA>" +
            "                   </importeOperacion>" +
            "                   <indicadorGastos>\(params.noSepaTransferInput.expensiveIndicator == .shared ? "C" : params.noSepaTransferInput.expensiveIndicator.name)</indicadorGastos>" +
            "                   <indicadorUrgencia>\(typeTransfer)</indicadorUrgencia>" +
            "                   <bic>\(params.noSepaTransferInput.beneficiaryAccount.swift ?? "")</bic>" +
            "                   <contratoOrdenante>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.noSepaTransferInput.originAccountDTO.oldContract?.bankCode ?? "")</EMPRESA>" +
            "                           <CENTRO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.branchCode ?? "")</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.product ?? "")</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "                   </contratoOrdenante>" +
            "               </entrada>" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
        "        </soapenv:Envelope>"
    }
}

public struct ValidationSwiftRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String    
    public let noSepaTransferInput: NoSEPATransferInput
}
