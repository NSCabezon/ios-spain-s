public class GetClausesPensionMifidRequest: BSANSoapRequest<GetClausesPensionMifidRequestParams, GetClausesPensionMifidHandler, GetClausesPensionMifidResponse, GetClausesPensionMifidParser> {
    public static let SERVICE_NAME = "obtenerClausulasPlanMIFID_LA"
    
    public override var serviceName: String {
        return GetClausesPensionMifidRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/PLANE1/Aportacionplan_la/F_plane1_aportacionplan_la/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>" +
            "        \(getSecurityHeader(params.token))" +
            "   </soapenv:Header>" +
            "   <soapenv:Body>" +
            "       <v1:\(serviceName) facade=\"\(facade)\">" +
            "         <entrada>" +
            "            <datosCabecera>" +
            "             <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>" +
            "             </idioma>" +
            "             <empresaAsociada>\(BSANHeaderData.DEFAULT_LINKED_COMPANY_SAN_ES)</empresaAsociada>" +
            "            </datosCabecera>" +
            "            <datosConexion>" +
            "             <cliente>" +
            "               <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "               <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "             </cliente>" +
            "             <canalMarco>\(params.userDataDTO.channelFrame ?? "")</canalMarco>" +
            "            </datosConexion>" +
            "            <contratoPlanes>" +
            "             <CENTRO>" +
            "              <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "              <CENTRO>\(params.branchCode)</CENTRO>" +
            "             </CENTRO>" +
            "             <PRODUCTO>\(params.product)</PRODUCTO>" +
            "             <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "            </contratoPlanes>" +
            "            <importePlan>" +
            "              <IMPORTE>\(params.amountValue)</IMPORTE>" +
            "              <DIVISA>\(params.currency)</DIVISA>" +
            "            </importePlan>" +
            "            <subtipoProducto>" +
            "             <SUBTIPO_DE_PRODUCTO>\(params.productSubtype)</SUBTIPO_DE_PRODUCTO>" +
            "            </subtipoProducto>" +
            "            <sentidoOper>C</sentidoOper>" +
            "            <usuarioMifid>" +
            "              <EMPRESA>0049</EMPRESA>" +
            "              <CODIGO_ALFANUM_3>PLP</CODIGO_ALFANUM_3>" +
            "            </usuarioMifid>" +
            "            <fechaSituacion/>" +
            "            <indForm>C</indForm>" +
            "            <tipoServicio>" +
            "              <EMPRESA>0049</EMPRESA>" +
            "              <COD_ALFANUM>EJ</COD_ALFANUM>" +
            "            </tipoServicio>" +
            "            <tipoOperacion>C</tipoOperacion>" +
            "            <indCall>S</indCall>" +
            "            <centroPeticionario>" +
            "             <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "             <CENTRO>\(params.branchCode)</CENTRO>" +
            "            </centroPeticionario>" +
            "            <codigoPlan>00\(params.productSubtype)</codigoPlan>" +
            "            <tipoCuestionario/>" +
            "            <descripcionCuestionario/>" +
            "            <nombreEvaluado>\(params.holder)</nombreEvaluado>" +
            "            <nombreFirmante>\(params.holder)</nombreFirmante>" +
            "            <claveSigaOrigen/>" +
            "           <claveSigaDestino/>" +
            "           <subtipoProductoCtoOrigen>" +
            "            <TIPO_DE_PRODUCTO>" +
            "             <EMPRESA/>" +
            "             <TIPO_DE_PRODUCTO>\(params.productType)</TIPO_DE_PRODUCTO>" +
            "            </TIPO_DE_PRODUCTO>" +
            "            <SUBTIPO_DE_PRODUCTO>\(params.productSubtype)</SUBTIPO_DE_PRODUCTO>" +
            "           </subtipoProductoCtoOrigen>" +
            "           <contratoOrigen>" +
            "            <CENTRO>" +
            "             <EMPRESA>\(params.bankCode)</EMPRESA>" +
            "             <CENTRO>\(params.branchCode)</CENTRO>" +
            "            </CENTRO>" +
            "            <PRODUCTO>\(params.productType)</PRODUCTO>" +
            "            <NUMERO_DE_CONTRATO>\(params.contractNumber)</NUMERO_DE_CONTRATO>" +
            "            </contratoOrigen>" +
            "         </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}
