import CoreDomain
import Foundation

public class CheckExtractPdfRequest: BSANSoapRequest <CheckExtractPdfRequestParams, CheckExtractPdfHandler, CheckExtractPdfResponse, CheckExtractPdfParser> {
    
    public static let serviceName = "consultaPdfExtractoLa"
    
    public override var serviceName: String {
        return CheckExtractPdfRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Pdfextractola/F_tarsan_pdfextractola/"
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
        
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <datosConexion>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   \(params.userDataDTO.getUserDataWithChannel().replace("contratoMulticanal", "contrato"))" +
            "                   <empresa>\(params.company)</empresa>" +
            "               </datosConexion>" +
            "               <entrada>" +
            XMLHelper.getContractXML(parentKey: "contrato", company: params.bankCode, branch: params.branchCode, product: params.product, contractNumber: params.contractName) +
            "                   <fechaInicio>\(fromDateFilterString)</fechaInicio>" +
            "                   <fechaFin>\(toDateFilterString)</fechaFin>" +
            "                   <IsPCAS>\(params.isPCAS ? "S" : "")</IsPCAS>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
