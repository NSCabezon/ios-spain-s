//
//  RepositoryChecker.swift
//  PersonalArea
//
//  Created by Juan Carlos López Robles on 3/3/20.
//

import Foundation
import SANLegacyLibrary

public func checkRepositoryResponse<T>(_ bsanResponse: BSANResponse<T>) throws -> T? {
    if bsanResponse.isSuccess() {
        return try bsanResponse.getResponseData()
    }
    throw NSError(domain: "", code: 0, userInfo: nil)
}

public func checkRepositoryResponse<T>(_ repositoryResponse: RepositoryResponse<T>) throws -> T? {
    if repositoryResponse.isSuccess() {
        return try repositoryResponse.getResponseData()
    }
    throw NSError(domain: "", code: 0, userInfo: nil)
}
