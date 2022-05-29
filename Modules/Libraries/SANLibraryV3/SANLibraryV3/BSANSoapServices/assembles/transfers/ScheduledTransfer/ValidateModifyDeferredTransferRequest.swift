import CoreDomain
import Foundation

public class ValidateModifyDeferredTransferRequest: BSANSoapRequest<ValidateModifyDeferredTransferRequestParams, ValidateModifyDeferredTransferHandler, ValidateModifyDeferredTransferResponse, ValidateModifyDeferredTransferParser> {
    
    private static let SERVICE_NAME = "validarModificarDiferidaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ValidateModifyDeferredTransferRequest.SERVICE_NAME
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
            "          <firma>\(getSignatureXmlFormatP(signatureDTO: params.signatureDTO))</firma>" +
            "          <tokenPasos>\(params.dataToken)</tokenPasos>" +
            "          <contratoOrdenante>" +
            "               <PAIS>\(params.originIban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.originIban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.originIban.codBban30)</CODBBAN>" +
            "           </contratoOrdenante>" +
            "          <divisaContratoOrdenante>\(params.orderingCurrency)</divisaContratoOrdenante>" +
            "          <beneficiario> " +
            "               <TIPO_DE_ACTUANTE>" +
            "                   <EMPRESA>\(params.actingBeneficiary.company ?? "")</EMPRESA>" +
            "                   <COD_TIPO_DE_ACTUANTE>\(params.actingBeneficiary.alphanumericCode ?? "")</COD_TIPO_DE_ACTUANTE>" +
            "               </TIPO_DE_ACTUANTE>" +
            "               <NUMERO_DE_ACTUANTE>\(params.actingNumber)</NUMERO_DE_ACTUANTE>" +
            "          </beneficiario>" +
            "          <fechaProximaEjecucion>\(nextExecutionDate)</fechaProximaEjecucion>" +
            "          <Importe>" +
            "               <IMPORTE>\(AmountFormats.getValueForWS(value: params.amount.value))</IMPORTE>" +
            "               <DIVISA>\(params.amount.currency?.currencyName ?? "")</DIVISA>" +
            "          </Importe>" +
            "          <concepto>\(params.concept)</concepto>" +
            "            <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>" +
            "          <cuentaIBANBeneficiario>" +
            "               <PAIS>\(params.beneficiaryIban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.beneficiaryIban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.beneficiaryIban.codBban30)</CODBBAN>" +
            "           </cuentaIBANBeneficiario>" +
            "           <tipoOperacion>" +
            "               <NATURALEZA_PAGO_MISPAG>" +
            "                   <EMPRESA>\(params.operationType.company ?? "")</EMPRESA>" +
            "                   <COD_ALFANUM>\(params.operationType.alphanumericCode ?? "")</COD_ALFANUM>" +
            "               </NATURALEZA_PAGO_MISPAG>" +
            "               <IND_TIP_OPERACION>\(params.indOperationType)</IND_TIP_OPERACION>" +
            "           </tipoOperacion>" +
            "          <tipoSEPA>\(params.sepaType)</tipoSEPA>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ValidateModifyDeferredTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let signatureDTO: SignatureDTO
    public let dataToken: String
    public let orderingCurrency: String
    public let originIban: IBANDTO
    public let beneficiaryIban: IBANDTO
    public let actingBeneficiary: InstructionStatusDTO
    public let nextExecutionDate: DateModel?
    public let amount: AmountDTO
    public let concept: String
    public let indicatorResidence: Bool
    public let operationType: InstructionStatusDTO
    public let sepaType: String
    public let actingNumber: String
    public let indOperationType: String
}


