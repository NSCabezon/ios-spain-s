//
//  ResponseInterceptor.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation
import CoreFoundationLib

public protocol NetworkResponseInterceptor {
    func interceptResponse(_ response: NetworkResponse) throws -> Result<NetworkResponse, Error>
}

public extension Result where Success == NetworkResponse, Failure == Error {

    
    /// A method to transform a Result<SoapResponse, Error> to a Result<XMLDecodable, Error>
    /// - Parameter decodable: The XMLDecodable type to be returned
    /// - Returns: A Result with a Decodable as success
    func flatMap<AnyDecodable: XMLDecodable>(toXMLDecodable decodable: AnyDecodable.Type) -> Result<AnyDecodable, Error> {
        return flatMap {
            guard let response = AnyDecodable(decoder: XMLDecoder(data: $0.data)) else { return .failure(RepositoryError.parsing) }
            return .success(response)
        }
    }
}

public extension Result where Success: XMLDecodable, Failure == Error {
    
    /// A method to transform a Result<XMLDecodable, Error> to a Result<Void, Error>
    /// - Returns: A Result with a Void as success
    func mapToVoid() -> Result<Void, Error> {
        return map { _ in
            Void()
        }
    }
    
    func store(on storage: Storage) {
        guard let data = try? get() else { return }
        storage.store(data)
    }
}
