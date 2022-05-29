//
//  SoapErrorInterceptor.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import CoreDomain
import SANServicesLibrary
import SANLegacyLibrary
import CoreFoundationLib

struct SoapErrorInterceptor: NetworkResponseInterceptor {
    
    let errorKey: String
    let descriptionKey: String
    
    func interceptResponse(_ response: NetworkResponse) throws -> Result<NetworkResponse, Error> {
        let decoder = XMLDecoder(data: response.data)
        if let faultCode: String = decoder.decode(key: "faultcode"),
           faultCode.lowercased().contains("invalidsecurity") || faultCode.lowercased().contains("failedauthentication") {
            throw CoreExceptions.unauthorized
        }
        guard
            let errorCode: String = decoder.decode(key: self.errorKey)
        else {
            return .success(response)
        }
        let description: String? = decoder.decode(key: self.descriptionKey)
        let error = NSError(domain: "soap.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: description ?? errorCode])
        return .failure(RepositoryError.errorWithCode(error))
    }
}
