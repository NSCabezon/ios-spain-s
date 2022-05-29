//
//  BSANDataProviderProtocol.swift
//  SANLegacyLibrary
//
//  Created by Victor Carrilero García on 21/01/2021.
//

import Foundation

public protocol BSANDataProviderProtocol {
    func getAuthCredentialsProvider() throws -> AuthCredentialsProvider
    func getLanguageISO() throws -> String
    func getDialectISO() throws -> String
}
