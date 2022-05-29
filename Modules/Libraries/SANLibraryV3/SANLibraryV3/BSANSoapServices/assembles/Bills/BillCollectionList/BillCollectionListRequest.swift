//

import Foundation

public class BillCollectionListRequest: BSANSoapRequest<BillCollectionListRequestParams, BillCollectionListHandler, BillCollectionListResponse, BillCollectionListParser> {
    
    static public var serviceName = "consultaRecaudaciones_LA"
    
    public override var serviceName: String {
        return BillCollectionListRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PARETR/Pagorecibos_la/F_paretr_pagorecibos_la/ACPARETRPagosRecibos/v1"
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
                        <cliente>
                            <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>
                            <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                        </cliente>
                        <cuentaCargo>
                            <CENTRO>
                                <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </cuentaCargo>
                        <idioma>
                            <IDIOMA_ISO>\(params.language)</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                        </idioma>
                        <empresa>\(params.userDataDTO.company ?? "")</empresa>
                        <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
                    </datosConexion>
                    <entrada>
                        <codigoEmisora>\(params.transmitterCode)</codigoEmisora>
                        <nombreRecaudacion></nombreRecaudacion>
                    </entrada>
                    \(params.paginationDTO?.repositionXML ?? emptyPagination)
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
    
    var emptyPagination: String {
        return """
        <paginacion>
           <lista>
              <tipoRecaudacion></tipoRecaudacion>
           </lista>
           <indicadorPaginacion></indicadorPaginacion>
           <Repos_Empresa></Repos_Empresa>
           <Repos_TipoRecibo></Repos_TipoRecibo>
           <Repos_Emisora></Repos_Emisora>
           <Repos_CodRecibo></Repos_CodRecibo>
           <Repos_CodProducto></Repos_CodProducto>
           <Repos_CodAbreviado></Repos_CodAbreviado>
           <alecto></alecto>
           <aniveref></aniveref>
           <arecaabr></arecaabr>
           <arecaabr1></arecaabr1>
           <atipirec></atipirec>
           <centro_Recaudo>
              <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
              <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
           </centro_Recaudo>
           <campoabr></campoabr>
           <codcampo></codcampo>
           <codclasi></codclasi>
           <desclasi></desclasi>
           <descreca></descreca>
           <emitirec></emitirec>
           <centro>
              <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
              <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
           </centro>
           <existenc></existenc>
           <ffinrec></ffinrec>
           <fmtosal></fmtosal>
           <fmtoent></fmtoent>
           <lite13></lite13>
        </paginacion>
        """
    }
}
