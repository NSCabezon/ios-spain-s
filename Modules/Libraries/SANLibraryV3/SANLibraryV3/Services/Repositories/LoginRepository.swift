//
//  LoginRepository.swift
//  SANSpainLibrary
//
//  Created by José Carlos Estela Anguita on 17/5/21.
//

import SANSpainLibrary
import CoreDomain
import SANServicesLibrary

struct LoginDataRepository: LoginRepository {

    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let requestSyncronizer: RequestSyncronizer

    func loginWithUser(_ userName: String, magic: String, type: LoginTypeRepresentable) throws -> Result<Void, Error> {
        let nameSpace = "http://www.isban.es/webservices/TECHNICAL_FACADES/Security/F_facseg_security/internet/"
        let facade = "loginServicesNSegSAN"
        let request = SoapSpainRequest(
            method: "",
            serviceName: "authenticateCredential",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/SANMOV_IPAD_NSeg_ENS/ws/SANMOV_Def_Listener",

            input: LoginRequest(userName: userName, magic: magic, type: type)
        )
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                BodySoapInterceptor(type: .vBody, version: .n0, nameSpace: nameSpace, facade: facade),
                EnvelopeSoapInterceptor(type: .vEnvelope, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
            ]
        )
        let result: Result<AuthenticationTokenDto, Error> = response.flatMap(toXMLDecodable: AuthenticationTokenDto.self)
        result.store(on: self.storage)
        return result.mapToVoid()
    }
}
