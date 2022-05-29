import CoreDomain

public class GetTransactionsContractEasyPayRequest: BSANSoapRequest<GetTransactionsContractEasyPayRequestParams, GetTransactionsContractEasyPayHandler, GetTransactionsContractEasyPayResponse, GetTransactionsContractEasyPayParser> {
    public static let SERVICE_NAME = "consultarMovimientosContrato_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Mvtospagofacil_la/F_tarsan_mvtospagofacil_la/internet/"
    }
    
    public override var serviceName: String {
        return GetTransactionsContractEasyPayRequest.SERVICE_NAME
    }
    
    private var emptyReposMovimientosContrato: String {
        return "<datosRepag>" +
            "               <JCODMONS/>" +
            "               <JDIAMOVT/>" +
            "               <JFECOPER/>" +
            "               <CONTE03/>" +
            "               <JCTOSALD/>" +
            "               <OPBANCARIA>" +
            "                  <OPERACION_BASICA>001</OPERACION_BASICA>" +
            "                  <OPERACION_BANCARIA>020</OPERACION_BANCARIA>" +
            "               </OPBANCARIA>" +
            "               <JFECANOT/>" +
            "               <NUMDGO/>" +
            "               <NUMMOV/>" +
            "               <TERMBTO/>" +
            "               <centroOrigen>" +
            "                  <EMPRESA/>" +
            "                  <CENTRO/>" +
            "               </centroOrigen>" +
            "            </datosRepag>"
    }
    
    override var message: String {
        let fromDateFilterString: String
        let toDateFilterString: String
        if let date = params.dateFilter?.fromDateModel?.date {
            fromDateFilterString = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            fromDateFilterString = ""
        }
        if let date = params.dateFilter?.toDateModel?.date {
            toDateFilterString = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            toDateFilterString = ""
        }
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "     <soapenv:Header>"
            + "     \(getSecurityHeader(params.token))"
            + "     </soapenv:Header>"
            + "     <soapenv:Body>"
            + "        <v1:\(serviceName) facade=\"\(facade)\">"
            + "         <entrada>"
            + "            <operacionLoR>L</operacionLoR>"
            + "            <fechaDesde>\(fromDateFilterString)</fechaDesde>"
            + "            <fechaHasta>\(toDateFilterString)</fechaHasta>"
            + "             <contratoTarjeta>"
            + "                 <CENTRO>"
            + "                     <EMPRESA>\(params.bankCode)</EMPRESA>"
            + "                     <CENTRO>\(params.branchCode)</CENTRO>"
            + "                 </CENTRO>"
            + "                 <PRODUCTO>\(params.product)</PRODUCTO>"
            + "                 <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>"
            + "             </contratoTarjeta>"
            + "                \(params.pagination?.repositionXML.replace("datosRepaginacion", "datosRepag") ?? emptyReposMovimientosContrato)"
            + "         </entrada>"
            + "         <datosConexion>"
            + "         \(params.userDataDTO.datosUsuarioWithEmpresa)"
            + "         </datosConexion>"
            + "          <datosCabecera>"
            + "               <idioma>"
            + "                   <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
            + "                   <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
            + "               </idioma>"
            + "         </datosCabecera>"
            + "       </v1:\(serviceName)>"
            + "     </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
}
