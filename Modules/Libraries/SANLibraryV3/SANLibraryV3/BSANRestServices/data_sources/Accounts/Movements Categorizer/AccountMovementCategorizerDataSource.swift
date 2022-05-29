//
//  AccountMovementCategorizerDataSource.swift
//  SANLibraryV3
//
//  Created by Boris Chirino Fernandez on 22/12/2020.
//

import Foundation

public final class AccountMovementCategorizerDataSource: AccountMovementCategorizerDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let apiBasePath = "/api/v1/"
    private let headers = ["X-Santander-Channel" : "RML"]
    private let categoryServicePath = "category/"
    private let categorizerServiceName = "movement"
    private let bsanDataProvider: BSANDataProvider

    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    func loadAccountTransactionCategory(params: TransactionCategorizerInputParams) throws -> BSANResponse<TransactionCategorizerDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + apiBasePath + categoryServicePath + categorizerServiceName
        return try executeRestCall(serviceName: categorizerServiceName,
                                   serviceUrl: url,
                                   queryParam: nil,
                                   body: Body(bodyParam: params),
                                   requestType: .post,
                                   headers: headers,
                                   responseEncoding: .utf8)
    }
}
