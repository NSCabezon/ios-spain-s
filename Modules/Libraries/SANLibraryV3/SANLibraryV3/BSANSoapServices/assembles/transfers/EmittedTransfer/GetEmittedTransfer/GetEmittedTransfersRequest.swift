import CoreDomain
import Foundation

public class GetEmittedTransfersRequest: BSANSoapRequest<GetEmittedTransferRequestParams, GetEmittedTransfersHandler, GetEmittedTransfersResponse, GetEmittedTransfersParser> {
    
    private static let SERVICE_NAME = "listaEmitidasLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Consultas_transf_la/F_trasan_consultas_transf_la/"
    }
    
    public override var serviceName: String {
        return GetEmittedTransfersRequest.SERVICE_NAME
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
        
        let operationType = params.paginationDTO != nil ? "R" : "L"
        let pagination = params.paginationDTO?.repositionXML ?? getEmptyPagination()
        let amountFrom = params.amountFrom ?? AmountDTO()
        let amountTo = params.amountTo ?? AmountDTO()

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
            "           <contrato>" +
            "              <CENTRO>" +
            "                 <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "                 <CENTRO>\(params.branchCode)</CENTRO>" +
            "              </CENTRO>" +
            "              <PRODUCTO>\(params.product)</PRODUCTO>" +
            "              <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "            </contrato>" +
            "         </datosConexion>" +
            "         <filtro>" +
            "            <importeDesde>" +
            "               <IMPORTE>\(amountFrom.getDecimalPart())</IMPORTE>" +
            "               <DIVISA>\(amountFrom.currency?.currencyName ?? "")</DIVISA>" +
            "            </importeDesde>" +
            "            <importeHasta>" +
            "               <IMPORTE>\(amountTo.getDecimalPart())</IMPORTE>" +
            "               <DIVISA>\(amountTo.currency?.currencyName ?? "")</DIVISA>" +
            "            </importeHasta>" +
            "            <fechaDesde>\(fromDateFilterString)</fechaDesde>" +
            "            <fechaHasta>\(toDateFilterString)</fechaHasta>" +
            "            <indicadorOperacion>\(operationType)</indicadorOperacion>" +
            "         </filtro>" +
            "          \(pagination)" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
            "</soapenv:Envelope>"
    }
    
    private func getEmptyPagination() -> String {
        return "<paginacion>" +
                "       <indRutInterTrfInt/>" +
                "            <indMasDatTrfInt/>" +
                "            <fecEjecTrfInt/>" +
                "            <impTrfInt>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impTrfInt>" +
                "            <ordSerTrfInt>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerTrfInt>" +
                "            <indRutInterPagElTrf/>" +
                "            <indMasDatPagElTrf/>" +
                "            <fecEjecPagElTrf/>" +
                "            <impPagElTrf>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impPagElTrf>" +
                "            <ordSerPagElTrf>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerPagElTrf>" +
                "            <indRutInterPagElRm/>" +
                "            <indMasDatPagElRm/>" +
                "            <fecEjecPagElRm/>" +
                "            <impPagElRm>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impPagElRm>" +
                "            <ordSerPagElRm>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerPagElRm>" +
                "            <indRutInterTrfNc/>" +
                "            <indMasDatTrfNc/>" +
                "            <fecEjecRpHTrfNc/>" +
                "            <impRpHTrfNc>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impRpHTrfNc>" +
                "            <ordSerRpHTrfNc>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerRpHTrfNc>" +
                "            <impRpITrfNc>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impRpITrfNc>" +
                "            <ordSerRpITrfNc>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerRpITrfNc>" +
                "            <adeudo>" +
                "               <EMPRESA/>" +
                "               <CENTRO/>" +
                "            </adeudo>" +
                "            <indRutInterPagTrfIntHH/>" +
                "            <indMasDatPagTrfIntHH/>" +
                "            <fecEjecPagTrfIntHH/>" +
                "            <impPagTrfIntHH>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impPagTrfIntHH>" +
                "            <ordSerPagTrfIntHH>" +
                "               <CENTRO>" +
                "                  <EMPRESA/>" +
                "                  <CENTRO/>" +
                "               </CENTRO>" +
                "               <PRODUCTO/>" +
                "               <NUMERO_DE_ORDEN/>" +
                "            </ordSerPagTrfIntHH>" +
                "            <indRutInterPagTrfIntOJ/>" +
                "            <indMasDatPagTrfIntOJ/>" +
                "            <fecEjecPagTrfIntOJ/>" +
                "            <impPagTrfIntOJ>" +
                "               <IMPORTE/>" +
                "               <DIVISA/>" +
                "            </impPagTrfIntOJ>" +
                "            <referenciaRemesa/>" +
                "</paginacion>"
    }
}

public struct GetEmittedTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractNumber: String
    public let paginationDTO: PaginationDTO?
    public let amountFrom: AmountDTO?
    public let amountTo: AmountDTO?
    public let dateFilter: DateFilter?
}
