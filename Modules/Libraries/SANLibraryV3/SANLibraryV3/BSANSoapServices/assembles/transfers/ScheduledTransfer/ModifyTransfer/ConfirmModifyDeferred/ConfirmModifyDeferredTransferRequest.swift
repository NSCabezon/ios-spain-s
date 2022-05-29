import CoreDomain
import Foundation

public class ConfirmModifyDeferredTransferRequest: BSANSoapRequest<ConfirmModifyDeferredTransferRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    private static let SERVICE_NAME = "confirmarModificarDiferidaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ConfirmModifyDeferredTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        let nextExecutionDate: String
        if let date = params.nextExecutionDate?.date {
            nextExecutionDate = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            nextExecutionDate = ""
        }
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "       <datosConexion>" +
            "            <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "            \(params.userDataDTO.getClientChannelWithCompany())" +
            "         </datosConexion>" +
            "        <entrada>" +
            "          <tokenPasos>\(params.dataToken)</tokenPasos>" +
            "          <ticket>\(params.ticket)</ticket>" +
            "          <codigoOTP>\(params.otpCode)</codigoOTP>" +
            "          <numeroOrdenCabecera>\(params.headerOrderNumber)</numeroOrdenCabecera>" +
            "          <tipoBeneficiario>" +
            "               <EMPRESA>\(params.actingBeneficiary.company ?? "")</EMPRESA>" +
            "               <COD_TIPO_DE_ACTUANTE>\(params.actingBeneficiary.alphanumericCode ?? "")</COD_TIPO_DE_ACTUANTE>" +
            "           </tipoBeneficiario>" +
            "          <nombreCompletoBeneficiario>\(params.beneficiaryName)</nombreCompletoBeneficiario>" +
            "          <fechaProximaEjecucion>\(nextExecutionDate)</fechaProximaEjecucion>" +
            "          <importe>" +
            "               <IMPORTE>\(AmountFormats.getValueForWS(value: params.amount.value))</IMPORTE>" +
            "               <DIVISA>\(params.amount.currency?.currencyName ?? "")</DIVISA>" +
            "          </importe>" +
            "          <concepto>\(params.concept)</concepto>" +
            "          <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>" +
            "          <cuentaIBANOrdenante>" +
            "               <PAIS>\(params.originIban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.originIban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.originIban.codBban30)</CODBBAN>" +
            "           </cuentaIBANOrdenante>" +
            "          <cuentaIBANBeneficiario>" +
            "               <PAIS>\(params.beneficiaryIban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.beneficiaryIban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.beneficiaryIban.codBban30)</CODBBAN>" +
            "           </cuentaIBANBeneficiario>" +
            "           <indicadorUrgencia>N</indicadorUrgencia>" +
            "           <tipoOperacion>" +
            "               <NATURALEZA_PAGO_MISPAG>" +
            "                   <EMPRESA>\(params.operationType.company ?? "")</EMPRESA>" +
            "                   <COD_ALFANUM>\(params.operationType.alphanumericCode ?? "")</COD_ALFANUM>" +
            "               </NATURALEZA_PAGO_MISPAG>" +
            "               <IND_TIP_OPERACION>\(params.indOperationType)</IND_TIP_OPERACION>" +
            "           </tipoOperacion>" +
            "           <codOperacion>\(params.operationCode)</codOperacion>" +
            "           <paisDestino>\(params.country)</paisDestino>" +
            "           <bic></bic>" +
            "           <divisaIbanOrdenante>\(params.orderingCurrency)</divisaIbanOrdenante>" +
            "           \(getTrusteerData(params.trusteerInfo, withUrl: "/mobile/TransferenciaDiferidaSEPAModif"))" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}


public struct ConfirmModifyDeferredTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let trusteerInfo: TrusteerInfoDTO?
    
    public let otpCode: String
    public let dataToken: String
    public let ticket: String
    
    public let orderingCurrency: String
    public let originIban: IBANDTO
    public let beneficiaryIban: IBANDTO
    public let actingBeneficiary: InstructionStatusDTO
    public let nextExecutionDate: DateModel?
    public let amount: AmountDTO
    public let concept: String
    public let indicatorResidence: Bool
    public let operationType: InstructionStatusDTO
    public let headerOrderNumber: String
    public let beneficiaryName: String
    public let operationCode: String
    public let country: String
    public let indOperationType: String
}
