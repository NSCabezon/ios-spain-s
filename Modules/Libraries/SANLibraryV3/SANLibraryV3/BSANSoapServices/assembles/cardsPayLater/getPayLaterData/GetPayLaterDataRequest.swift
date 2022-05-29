public class GetPayLaterDataRequest: BSANSoapRequest <GetPayLaterDataRequestParams, GetPayLaterDataHandler, GetPayLaterDataResponse, GetPayLaterDataParser> {
    
    public static let SERVICE_NAME = "obtenerDatosDeuda_LA"
    
    public override var serviceName: String {
        return GetPayLaterDataRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Altapagoluego_la/F_tarsan_altapagoluego_la/internet/"
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
            + "               <IMPORTE></IMPORTE>"
            + "               <DIVISA></DIVISA>"
            + "            </importeOperacion>"
            + "             <contratoTarjeta>"
            + "                 <CENTRO>"
            + "                     <EMPRESA>\(params.bankCode)</EMPRESA>"
            + "                     <CENTRO>\(params.branchCode)</CENTRO>"
            + "                 </CENTRO>"
            + "                 <PRODUCTO>\(params.product)</PRODUCTO>"
            + "                 <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>"
            + "             </contratoTarjeta>"
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
