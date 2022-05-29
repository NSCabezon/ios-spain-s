import CoreDomain
import Foundation

class ConfirmModifyPeriodicTransferRequest: BSANSoapRequest<ConfirmModifyPeriodicTransferRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    private static let SERVICE_NAME = "confirmarModificarPeriodicaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    override var serviceName: String {
        return ConfirmModifyPeriodicTransferRequest.SERVICE_NAME
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
            endDateValidity = "9999-12-31"
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
            "           <fechaInicioVigencia>\(startDateValidity)</fechaInicioVigencia>" +
            "           <fechaFinVigencia>\(endDateValidity)</fechaFinVigencia>" +
            "           <periodicidad>" +
            "               <dia>\(params.startDateValidity?.day ?? "1")</dia>" +
            "               <mes>\(params.periodicalType.rawValue)</mes>" +
            "               <tiempo>\(params.periodicalType.rawValue)</tiempo>" +
            "            </periodicidad>" +
            "            <indicadorPeriodicidad>" +
            "               <EMPRESA>\(params.periodicityIndicator.company ?? "")</EMPRESA>" +
            "               <CODIGO_ALFANUM_3>\(params.periodicityIndicator.alphanumericCode ?? "")</CODIGO_ALFANUM_3>" +
            "            </indicadorPeriodicidad>" +
            "           <divisaIbanOrdenante>\(params.orderingCurrency)</divisaIbanOrdenante>" +
            "            <indicadorTratamientoEmis>\(params.scheduledDayType.rawValue)</indicadorTratamientoEmis>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}


struct ConfirmModifyPeriodicTransferRequestParams {
    let token: String
    let userDataDTO: UserDataDTO
    let dialectISO: String
    let languageISO: String
    let otpCode: String
    let dataToken: String
    let ticket: String
    let orderingCurrency: String
    let originIban: IBANDTO
    let beneficiaryIban: IBANDTO
    let actingBeneficiary: InstructionStatusDTO
    let indOperationType: String
    let nextExecutionDate: DateModel?
    let amount: AmountDTO
    let concept: String
    let indicatorResidence: Bool
    let operationType: InstructionStatusDTO
    let headerOrderNumber: String
    let beneficiaryName: String
    let operationCode: String
    let country: String
    let startDateValidity: DateModel?
    let endDateValidity: DateModel?
    let periodicityIndicator: InstructionStatusDTO
    let periodicalType: PeriodicalTypeTransferDTO
    let scheduledDayType: ScheduledDayDTO
}



