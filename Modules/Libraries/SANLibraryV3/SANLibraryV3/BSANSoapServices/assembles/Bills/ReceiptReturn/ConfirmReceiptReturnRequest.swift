public class ConfirmReceiptReturnRequest: BSANSoapRequest<ConfirmReceiptReturnRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static public var serviceName = "confirmarDevolucionReciboSEPA_LA"
    
    public override var serviceName: String {
        return ConfirmReceiptReturnRequest.serviceName
    }

    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Devrecibos_la/F_recsan_devrecibos_la/internet/RECSANDR/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <datosConexion>
                        \(params.userDataDTO.datosUsuario)
                    </datosConexion>
                    <datosCabecera>
                        <idioma>\(serviceLanguage(params.language))</idioma>
                    </datosCabecera>
                    <entrada>
                        <datosFirma>
                            \(getSignatureXml(signatureDTO: params.signature))
                        </datosFirma>
                        <ordenServicio>
                            <CENTRO>
                                <EMPRESA>\(params.billDTO.creditorCompanyId)</EMPRESA>
                                <CENTRO>\(params.centro)</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.billDTO.codProd)</PRODUCTO>
                            <NUMERO_DE_ORDEN>\(params.billDTO.paymentOrderCode)</NUMERO_DE_ORDEN>
                        </ordenServicio>
                        <estado>\(params.billDetaildDTO.state.value)</estado>
                        <contratoDomiciliacion>
                            <CENTRO>
                                <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </contratoDomiciliacion>
                        <referencia>\(params.billDetaildDTO.mandateReference)</referencia>
                        <motivoDevolucion>
                            <SUBTIPO_DE_PRODUCTO>
                                <TIPO_DE_PRODUCTO>
                                    <EMPRESA>\(params.billDetaildDTO.productSubtype.company ?? "")</EMPRESA>
                                    <TIPO_DE_PRODUCTO>\(params.billDetaildDTO.productSubtype.productType ?? "")</TIPO_DE_PRODUCTO>
                                </TIPO_DE_PRODUCTO>
                                <SUBTIPO_DE_PRODUCTO>\(params.billDetaildDTO.productSubtype.productSubtype ?? "")</SUBTIPO_DE_PRODUCTO>
                            </SUBTIPO_DE_PRODUCTO>
                            <TIPO_DE_MOTIVO/>
                            <CODIGO_MOTIVO/>
                        </motivoDevolucion>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
