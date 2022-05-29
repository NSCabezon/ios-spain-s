//

import Foundation

public class ValidationNoSEPARequest: BSANSoapRequest<ValidationIntNoSEPARequestParams, ValidationNoSEPAHandler, ValidationNoSEPAResponse, ValidationNoSEPAParser> {
    
    private static let SERVICE_NAME = "validacionIntNoSEPA_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Emisioninter_la/F_trasan_emisioninter_la/"
    }
    
    public override var serviceName: String {
        return ValidationNoSEPARequest.SERVICE_NAME
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
        
        let beneficiaryAddress = params.noSepaTransferInput.beneficiaryAddress
        let bankAddress = params.noSepaTransferInput.beneficiaryAccount.bankData
        let accountDestination = params.noSepaTransferInput.beneficiaryAccount.account34
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "        <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <entrada>" +
            "                   <cuentaOrdenante>" +
            "                       <CENTRO>" +
            "                           <EMPRESA>\(params.noSepaTransferInput.originAccountDTO.oldContract?.bankCode ?? "")</EMPRESA>" +
            "                           <CENTRO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.branchCode ?? "")</CENTRO>" +
            "                       </CENTRO>" +
            "                       <PRODUCTO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.product ?? "")</PRODUCTO>" +
            "                       <NUMERO_DE_CONTRATO>\(params.noSepaTransferInput.originAccountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "                   </cuentaOrdenante>" +
            "                   <impEmision>" +
            "                       <IMPORTE>\(AmountFormats.getValueForWS(value: params.noSepaTransferInput.transferAmount.value))</IMPORTE>" +
            "                       <DIVISA>\(params.noSepaTransferInput.transferAmount.currency?.currencyName  ?? "")</DIVISA>" +
            "                   </impEmision>" +
            "                   <codPaisDestino>\(params.noSepaTransferInput.countryCode)</codPaisDestino>" +
            "                   <cuentaBeneficiarioTexto>\(accountDestination)</cuentaBeneficiarioTexto>" +
            "                   <nombreBeneficiario>\(params.noSepaTransferInput.beneficiary)</nombreBeneficiario>" +
            "                   <direccionBenef>\(beneficiaryAddress?.address ?? "")</direccionBenef>" +
            "                   <localidadBenef>\(beneficiaryAddress?.locality ?? "")</localidadBenef>" +
            "                   <paisBenef>\(beneficiaryAddress?.country ?? "")</paisBenef>" +
            "                   <bic>\(params.validationSwiftDTO?.beneficiaryBic ?? "")</bic>" +
            "                   <bancoAgenteFinanciero>\(bankAddress?.name ?? "")</bancoAgenteFinanciero>" +
            "                   <domicilioAgenteFinanciero>\(bankAddress?.address ?? "")</domicilioAgenteFinanciero>" +
            "                   <localidadAgenteFinanciero>\(bankAddress?.location ?? "")</localidadAgenteFinanciero>" +
            "                   <paisAgenteFinan>\(bankAddress?.country ?? "")</paisAgenteFinan>" +
            "                   <fechaEmision>\(dateOperation)</fechaEmision>" +
            "                   <indResidencia>\(params.noSepaTransferInput.indicatorResidence ? "S" : "N")</indResidencia>" +
            "                   <indGastos>" +
            "                       <EMPRESA>0049</EMPRESA>" +
            "                       <CODIGO_ALFANUM>\(params.noSepaTransferInput.expensiveIndicator == .shared ? "C" : params.noSepaTransferInput.expensiveIndicator.name)</CODIGO_ALFANUM>" +
            "                   </indGastos>" +
            "                   <indUrgencia>\(typeTransfer)</indUrgencia>" +
            "                   <concepto>\(params.noSepaTransferInput.concept ?? "")</concepto>" +
            "                   <divisaOrdenante>\(params.noSepaTransferInput.originAccountDTO.currency?.currencyName ?? "")</divisaOrdenante>" +
            "                   <paisOrdenante>\((params.noSepaTransferInput.originAccountDTO.iban?.countryCode ?? ""))</paisOrdenante>" +
            "                   <tipoCuentaInt>\(params.noSepaTransferInput.accountType)</tipoCuentaInt>" +
            "                   <indAutoFX>S</indAutoFX>" +
            "                   <indAcelera>A</indAcelera>" +
            "               </entrada>" +
            "               <cabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.userDataDTO.company ?? "")</empresaAsociada>" +
            "               </cabecera>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuario)</datosConexion>" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
        "        </soapenv:Envelope>"
    }
}

public struct ValidationIntNoSEPARequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let noSepaTransferInput: NoSEPATransferInput
    public let validationSwiftDTO: ValidationSwiftDTO?
}
