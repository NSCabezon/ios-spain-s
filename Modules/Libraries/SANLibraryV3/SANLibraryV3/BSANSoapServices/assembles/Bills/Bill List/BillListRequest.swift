//

import Foundation

public class BillListRequest: BSANSoapRequest<BillListRequestParams, BillListHandler, BillListResponse, BillListParser> {
    
    static public var serviceName = "listaRecibosLa"
    
    public override var serviceName: String {
        return BillListRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Cambiomasdomis_la/F_recsan_cambiomasdomis_la/ACRECSANCambioMasivo/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <datosConexion>
                        <idioma>
                        <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                        <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                        </idioma>
                        \(params.userDataDTO.getUserDataWithChannelAndCompany)
                    </datosConexion>
                    <filtro>
                        <cuenta>
                            <CENTRO>
                                <EMPRESA>\(params.accountDTO.contract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.accountDTO.contract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.accountDTO.contract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.accountDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </cuenta>
                        <fechaDesde>\(DateFormats.toString(date: params.fromDate.date, output: .YYYYMMDD))</fechaDesde>
                        <fechaHasta>\(DateFormats.toString(date: params.toDate.date, output: .YYYYMMDD))</fechaHasta>
                        <estadoRec>\(params.status.description)</estadoRec>
                    </filtro>
                    \(params.paginationDTO?.repositionXML ?? emptyPagination)
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
    
    var emptyPagination: String {
        return """
        <paginacion>
            <listaRecibosPaginacion>
                <recibo>
                    <CODPROD/>
                    <IDCENT>
                        <EMPRESA/>
                        <CENTRO/>
                    </IDCENT>
                    <IDEMPRD/>
                    <IDEMPRG/>
                    <NUMSOR/>
                </recibo>
            </listaRecibosPaginacion>
            <indicadorReposicionamiento></indicadorReposicionamiento>
            <FECDES/>
            <FECHASD/>
            <IDCENTC>
                <EMPRESA/>
                <CENTRO/>
            </IDCENTC>
            <IDCENTR>
                <EMPRESA/>
                <CENTRO/>
            </IDCENTR>
            <LISTASI/>
            <NUMECONR/>
            <IDPRODR/>
            <SENTTRAS>R</SENTTRAS>
            <ZFECHA/>
            <ZFECHAT/>
            <ZIDCENT>
                <EMPRESA/>
                <CENTRO/>
            </ZIDCENT>
            <ZIDEMPR/>
            <ZNUMSOR/>
            <IMPDESI/>
            <IMPHASI/>
            <TIPCA>2</TIPCA>
        </paginacion>
        """
    }
}
