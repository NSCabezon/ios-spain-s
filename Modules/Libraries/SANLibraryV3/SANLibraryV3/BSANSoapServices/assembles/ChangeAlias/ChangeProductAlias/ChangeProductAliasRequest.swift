//

import Foundation

class ChangeProductAliasRequest: BSANSoapRequest<ChangeProductAliasRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static var serviceName = "personalizarPosicionGlobal_LA"
    
    override var serviceName: String {
        return ChangeProductAliasRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/NUEBRO/Posicionglobal_la/F_nuebro_posicionglobal_la/internet/ACNUEBROPosGlo/v1"
    }
 
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                    <datosEntrada>
                        <DatosSeguridad>
                            <Canal>\(params.userDataDTO.channelFrame ?? "")</Canal>
                            <Persona>
                                <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>
                                <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>
                            </Persona>
                            <Empresa>\(params.userDataDTO.contract?.bankCode ?? "")</Empresa>
                            <Idioma>
                                <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                                <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                            </Idioma>
                            <Empresa_Asociada>\(params.linkedCompany)</Empresa_Asociada>
                        </DatosSeguridad>
                        <ListaSolicitada/>
                        <listaCuentas>
                          <cuenta>
                                <descripcion></descripcion>
                                <descripcionPersonalizada>\(params.newAlias)</descripcionPersonalizada>
                                <filtroValido>S</filtroValido>
                                <filtroValidoPersonalizado>S</filtroValidoPersonalizado>
                                <contratoNuevo>
                                    <CENTRO>
                                        <EMPRESA>\(params.accountDTO.contract?.bankCode ?? "")</EMPRESA>
                                        <CENTRO>\(params.accountDTO.contract?.branchCode ?? "")</CENTRO>
                                    </CENTRO>
                                    <PRODUCTO>\(params.accountDTO.contract?.product ?? "")</PRODUCTO>
                                    <NUMERO_DE_CONTRATO>\(params.accountDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                                </contratoNuevo>
                                <contratoViejo>
                                    <CENTRO>
                                        <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
                                        <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
                                    </CENTRO>
                                <SUBGRUPO>\(params.accountDTO.oldContract?.product ?? "")</SUBGRUPO>
                                <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                             </contratoViejo>
                          </cuenta>
                       </listaCuentas>
                       <listaDepositos>
                          <!--Zero or more repetitions:-->
                          <deposito>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contratoNuevo>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contratoNuevo>
                          </deposito>
                       </listaDepositos>
                       <listaFondos>
                          <!--Zero or more repetitions:-->
                          <fondo>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </fondo>
                       </listaFondos>
                       <listaOtrosSeguros>
                          <!--Zero or more repetitions:-->
                          <otrosSeguros>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </otrosSeguros>
                       </listaOtrosSeguros>
                       <listaPlanes>
                          <!--Zero or more repetitions:-->
                          <planes>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </planes>
                       </listaPlanes>
                       <listaPrestamos>
                          <!--Zero or more repetitions:-->
                          <prestamos>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contratoNuevo>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contratoNuevo>
                          </prestamos>
                       </listaPrestamos>
                       <listaSeguros>
                          <!--Zero or more repetitions:-->
                          <seguro>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </seguro>
                       </listaSeguros>
                       <listaSegurosCambio>
                          <!--Zero or more repetitions:-->
                          <segurosCambio>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contratoNuevo>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contratoNuevo>
                          </segurosCambio>
                       </listaSegurosCambio>
                       <listaUnitLink>
                          <!--Zero or more repetitions:-->
                          <unitLink>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </unitLink>
                       </listaUnitLink>
                       <listaUnitLinkMandato>
                          <!--Zero or more repetitions:-->
                          <unitLinkMandato>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </unitLinkMandato>
                       </listaUnitLinkMandato>
                       <listaValores>
                          <!--Zero or more repetitions:-->
                          <valor>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <filtroValido/>
                             <filtroValidoPersonalizado/>
                             <contrato>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contrato>
                          </valor>
                       </listaValores>
                       <listaCarteras>
                          <!--Zero or more repetitions:-->
                          <cartera>
                             <descripcion/>
                             <descripcionPersonalizada/>
                             <tipoIntervencion/>
                             <contratoPartenon>
                                <CENTRO>
                                   <EMPRESA/>
                                   <CENTRO/>
                                </CENTRO>
                                <PRODUCTO/>
                                <NUMERO_DE_CONTRATO/>
                             </contratoPartenon>
                             <indValido/>
                             <indValidoPersonalizado/>
                          </cartera>
                       </listaCarteras>
                    </datosEntrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
