public class ConfirmPayLaterRequest: BSANSoapRequest<ConfirmPayLaterRequestParams, ConfimPayLaterHandler, BSANSoapResponse, ConfimPayLaterParser> {
    public static let SERVICE_NAME = "altaConfirmaPagoLuego_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Altapagoluego_la/F_tarsan_altapagoluego_la/internet/"
    }
    
    public override var serviceName: String {
        return ConfirmPayLaterRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "     <soapenv:Header>"
            + "     \(getSecurityHeader(params.token))"
            + "     </soapenv:Header>"
            + "     <soapenv:Body>"
            + "       <v1:\(serviceName) facade=\"\(facade)\">"
            + "         <entrada>"
            + "            <importeOperacion>"
            + "               <IMPORTE>\(params.amountValue)</IMPORTE>"
            + "               <DIVISA>\(params.currency)</DIVISA>"
            + "            </importeOperacion>"
            + "             <contratoTarjeta>"
            + "                 <CENTRO>"
            + "                     <EMPRESA>\(params.bankCode)</EMPRESA>"
            + "                     <CENTRO>\(params.branchCode)</CENTRO>"
            + "                 </CENTRO>"
            + "                 <PRODUCTO>\(params.product)</PRODUCTO>"
            + "                 <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>"
            + "             </contratoTarjeta>"
            + "            <fechaOpera>\(DateFormats.toString(date: params.operationDate, output: DateFormats.TimeFormat.YYYYMMDD))</fechaOpera>"
            + "         </entrada>"
            + "         <datosConexion>"
            + "         \(params.userDataDTO.datosUsuarioWithEmpresa)"
            + "         </datosConexion>"
            + "          <datosCabecera>"
            + "               <idioma>"
            + "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "               </idioma>"
            + "               <empresaAsociada>\(params.linkedCompany)</empresaAsociada>"
            + "         </datosCabecera>"
            + "      </v1:\(serviceName)>"
            + "     </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
    
}
