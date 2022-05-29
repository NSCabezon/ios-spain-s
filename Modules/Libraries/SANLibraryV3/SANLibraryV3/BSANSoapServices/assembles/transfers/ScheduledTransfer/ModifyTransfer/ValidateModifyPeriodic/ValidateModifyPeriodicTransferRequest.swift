import CoreDomain
import Foundation

public class ValidateModifyPeriodicTransferRequest: BSANSoapRequest<ValidateModifyPeriodicTransferRequestParams, ValidateModifyPeriodicTransferHandler, ValidateModifyPeriodicTransferResponse, ValidateModifyPeriodicTransferParser> {
    
    private static let SERVICE_NAME = "validarModificarPeriodicaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ValidateModifyPeriodicTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let nextExecutionDate: String
        let startDateValidity: String
        let endDateValidity: String
        
        if let date = params.nextExecutionDate?.date {
            nextExecutionDate = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            nextExecutionDate = ""
        }
        
        if let date = params.startDateValidity?.date {
            startDateValidity = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            startDateValidity = ""
        }
        
        if let date = params.endDateValidity?.date {
            endDateValidity = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            endDateValidity = ""
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
            "            \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)" +
            "         </datosConexion>" +
            "        <entrada>" +
            "          <tokenPasos>\(params.dataToken)</tokenPasos>" +
            "          <contratoOrdenante>" +
            "               <PAIS>\(params.originIban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.originIban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.originIban.codBban30)</CODBBAN>" +
            "           </contratoOrdenante>" +
            "          <divisaContratoOrdenante>\(params.orderingCurrency)</divisaContratoOrdenante>" +
            "          <actuante> " +
            "               <TIPO_DE_ACTUANTE>" +
            "                   <EMPRESA>\(params.actingBeneficiary.company ?? "")</EMPRESA>" +
            "                   <COD_TIPO_DE_ACTUANTE>\(params.actingBeneficiary.alphanumericCode ?? "")</COD_TIPO_DE_ACTUANTE>" +
            "               </TIPO_DE_ACTUANTE>" +
            "               <NUMERO_DE_ACTUANTE>\(params.actingNumber)</NUMERO_DE_ACTUANTE>" +
            "          </actuante>" +
            "          <fechaProximaEjecucion>\(nextExecutionDate)</fechaProximaEjecucion>" +
            "          <Importe>" +
            "               <IMPORTE>\(AmountFormats.getValueForWS(value: params.amount.value))</IMPORTE>" +
            "               <DIVISA>\(params.amount.currency?.currencyName ?? "")</DIVISA>" +
            "          </Importe>" +
            "          <concepto>\(params.concept)</concepto>" +
            "          <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>" +
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
            "          </tipoOperacion>" +
            "          <fechaInicioVigencia>\(startDateValidity)</fechaInicioVigencia>" +
            "          <fechaFinVigencia>\(endDateValidity)</fechaFinVigencia>" +
            "          <indicadorTratamientoFechaEmis>" +
            "               <EMPRESA>\(params.dateIndicator.company ?? "")</EMPRESA>" +
            "               <CODIGO_ALFANUM>\(params.dateIndicator.alphanumericCode ?? "")</CODIGO_ALFANUM>" +
            "          </indicadorTratamientoFechaEmis>" +
            "          <indicadorPeriodicidad>" +
            "               <EMPRESA>\(params.periodicityIndicator.company ?? "")</EMPRESA>" +
            "               <CODIGO_ALFANUM_3>\(params.periodicityIndicator.alphanumericCode ?? "")</CODIGO_ALFANUM_3>" +
            "          </indicadorPeriodicidad>" +
            "          <periodicidad>" +
            "               <dia>\(params.startDateValidity?.day ?? "1")</dia>" +
            "               <mes>\(params.periodicalType.rawValue)</mes>" +
            "               <tiempo>\(params.periodicalType.rawValue)</tiempo>" +
            "          </periodicidad>" +
            "          <indicadorUrgencia>N</indicadorUrgencia>" +
            "          <tipoSEPA>\(params.sepaType)</tipoSEPA>" +
            "          <paisPago>\(params.countryCode)</paisPago>" +
            "          <firma>\(getSignatureXmlFormatP(signatureDTO: params.signatureDTO))</firma>" +
            "          <divisaIbanOrdenante>\(params.ibanOrderingCurrency)</divisaIbanOrdenante>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ValidateModifyPeriodicTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let signatureDTO: SignatureDTO
    public let dataToken: String
    public let orderingCurrency: String
    public let ibanOrderingCurrency: String
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
    public let countryCode: String
    public let startDateValidity: DateModel?
    public let endDateValidity: DateModel?
    public let dateIndicator: InstructionStatusDTO
    public let periodicityIndicator: InstructionStatusDTO
    public let scheduledDayType: ScheduledDayDTO
    public let periodicalType: PeriodicalTypeTransferDTO
}


