//
//  RequestInterceptor.swift
//  SANServicesLibrary
//
//  Created by Hernán Villamil on 30/11/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol NetworkRequestInterceptor {
    func interceptRequest(_ request: NetworkRequest) -> NetworkRequest
}

public extension Result where Success == NetworkResponse, Failure == Error {
    
    /// A method to transform a Result<RestResponse, Error> to a Result<Void, Error>
    /// - Returns: A Result with a Void as success
    func mapToVoid() -> Result<Void, Error> {
        return map { _ in
            Void()
        }
    }
    
    /// A method to transform a Result<RestResponse, Error> to a Result<Decodable, Error>
    /// - Parameter decodable: The Decodable type to be returned
    /// - Returns: A Result with a Decodable as success
    func flatMap<AnyDecodable: Decodable>(to decodable: AnyDecodable.Type) -> Result<AnyDecodable, Error> {
        return flatMap {
            do {
                let decoder = JSONDecoder()
                if let dateParseable = AnyDecodable.self as? SANLegacyLibrary.DateParseable.Type {
                    decoder.dateDecodingStrategy = .custom(dateParseable.decode)
                }
                let decoded = try decoder.decode(AnyDecodable.self, from: $0.data)
                return .success(decoded)
            } catch {
                return .failure(RepositoryError.error(error))
            }
        }
    }
}

extension Result where Success: Decodable, Failure == Error {
    
    /// A method to transform a Result<Decodable, Error> to a Result<Void, Error>
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
