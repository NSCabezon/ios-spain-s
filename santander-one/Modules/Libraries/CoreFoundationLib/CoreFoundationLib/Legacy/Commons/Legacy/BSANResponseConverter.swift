//
//  BSANResponseConverter.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 18/8/21.
//

import CoreDomain
import SANLegacyLibrary

public struct BSANResponseConverter {
    public static func convert<T, Reprensentable>(response: BSANResponse<T>) throws -> Result<Reprensentable, Error> {
        if response.isSuccess() {
            if T.self == Void.self, let representable = () as? Reprensentable {
                return .success(representable)
            }
            guard let data = try response.getResponseData() as? Reprensentable else { return .failure(RepositoryError.unknown) }
            return .success(data)
        } else {
            guard let errorMessage = try response.getErrorMessage()
            else { return .failure(RepositoryError.unknown) }
            let error = NSError(
                domain: "",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: errorMessage,
                    NSError.Constants.errorCodeKey: try response.getErrorCode()
                ]
            )
            return .failure(RepositoryError.errorWithCode(error))
        }
    }
}
