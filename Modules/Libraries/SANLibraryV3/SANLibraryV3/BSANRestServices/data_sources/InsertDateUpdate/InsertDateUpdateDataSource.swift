//
//  InsertDateUpdateDataSource.swift
//  GlobalPosition
//
//  Created by Carlos Monfort Gómez on 4/5/21.
//

import Foundation
import SANLegacyLibrary

public class InsertDateUpdateDataSource: InsertDateUpdateDataSourceProtocol {
    
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let basePath = "/api/v1"
    private let serviceName = "/bubble/insertUpdate"
    private let headers = ["X-Santander-Channel" : "RML", "Content-type" : "application/json"]
    
    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func insertDateUpdate() throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.serviceName
        try self.sanRestServices.executeRestCall(
            request: RestRequest(serviceName: self.serviceName,
                                 serviceUrl: url,
                                 body: nil,
                                 queryParams: [:],
                                 requestType: .post,
                                 headers: self.headers
            )
        )
        return BSANOkEmptyResponse()
    }
}
