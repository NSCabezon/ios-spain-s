//
//  AccountMovementCategorizerDataSourceProtocol.swift
//  SANLibraryV3
//
//  Created by Boris Chirino Fernandez on 22/12/2020.
//

protocol AccountMovementCategorizerDataSourceProtocol: RestDataSource {
    func loadAccountTransactionCategory(params: TransactionCategorizerInputParams) throws -> BSANResponse<TransactionCategorizerDTO>
}
