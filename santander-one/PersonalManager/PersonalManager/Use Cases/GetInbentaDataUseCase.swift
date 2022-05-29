//
//  GetInbentaDataUseCase.swift
//  PersonalManager
//
//  Created by alvola on 12/02/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol InbentaDataUseCaseProtocol {
    var nodes: [String] { get }
}

extension InbentaDataUseCaseProtocol {
    
    func getNodes(appConfigRepository: AppConfigRepositoryProtocol) -> [String: String] {
        return nodes.reduce([String: String]()) { result, node in
            var new = result
            new[node] = appConfigRepository.getString(node)
            return new
        }
    }
    
    func getParameters(defaultSegment: String = "", bsanManagersProvider: BSANManagersProvider) throws -> [String: String] {
        let isSmart = try bsanManagersProvider.getBsanUserSegmentManager().isSmartUser()
        let isSelect = try bsanManagersProvider.getBsanUserSegmentManager().isSelectUser()
        let isPb = try bsanManagersProvider.getBsanSessionManager().getUser().getResponseData()?.isPB == true
        let token = try bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let segment: String
        var tokenKey = "t"
        
        switch (isPb, isSelect, isSmart) {
        case (true, _, _):
            segment = "SPB"
        case (_, true, _):
            segment = "SELECT"
        case (_, _, true):
            segment = "123"
            tokenKey = "tm"
        default:
            segment = defaultSegment
        }
        
        return ["action": "fullScreen", "s": segment, tokenKey: token]
    }
}

class GetInbentaDataUseCase<Input, OkOutput>: UseCase<Input, OkOutput, StringErrorOutput>, InbentaDataUseCaseProtocol {
    var nodes: [String] {
        return []
    }
}
