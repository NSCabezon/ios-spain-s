//
//  LoginRequest.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import SANSpainLibrary
import SANServicesLibrary

struct LoginRequest: SoapBodyConvertible {
    let userName: String
    let magic: String
    let type: LoginTypeRepresentable
    
    var body: String {
        return """
        <CB_AuthenticationData i:type=":CB_AuthenticationData">
            <documento i:type=":documento">
                <CODIGO_DOCUM_PERSONA_CORP i:type="d:string">\(self.userName)</CODIGO_DOCUM_PERSONA_CORP>
                <TIPO_DOCUM_PERSONA_CORP i:type="d:string">\(self.type.type)</TIPO_DOCUM_PERSONA_CORP>
            </documento>
            <password i:type="d:string">\(self.magic)</password>
        </CB_AuthenticationData>
        <userAddress i:type="d:string">180.112.132.69</userAddress>
        """
    }
}
