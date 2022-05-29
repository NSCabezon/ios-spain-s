//
//  SKCustomerDetailsUseCase.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import SANSpainLibrary
import CoreFoundationLib
import ESCommons

public protocol SKCustomerDetailsUseCase {
    func getStatus() -> AnyPublisher<SantanderKeyStatusRepresentable, Error>
    func getDetail() -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error>
}

struct DefaultSKCustomerDetailsUseCase {
    private var repository: SantanderKeyOnboardingRepository
    private var compilation: SpainCompilationProtocol

    init(dependencies: SKCustomerDetailsDependenciesResolver) {
        repository = dependencies.external.resolve()
        compilation = dependencies.external.resolve()
    }
}

extension DefaultSKCustomerDetailsUseCase: SKCustomerDetailsUseCase {
    func getStatus() -> AnyPublisher<SantanderKeyStatusRepresentable, Error> {
        return self.repository.getClientStatusReactive(santanderKeyID: getSantanderKeyId(), deviceId: getDeviceId())
    }
    func getDetail() -> AnyPublisher<SantanderKeyDetailResultRepresentable, Error> {
        return self.repository.getSantanderKeyDetailReactive(sanKeyId: getSantanderKeyId()).eraseToAnyPublisher()
    }
}

private extension DefaultSKCustomerDetailsUseCase {
    func getDeviceId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                         account: compilation.keychainSantanderKey.deviceId,
                                         accessGroup: compilation.sharedTokenAccessGroup)
        if let deviceId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return deviceId
        }
        return nil
    }
    
    func getSantanderKeyId() -> String? {
        let lookupQuery = KeychainQuery(service: compilation.service,
                                         account: compilation.keychainSantanderKey.sankeyId,
                                         accessGroup: compilation.sharedTokenAccessGroup)
        if let deviceId = try? KeychainWrapper().fetch(query: lookupQuery) as? String {
            return deviceId
        }
        return nil
    }
}

public struct SantanderKeyGetDetailUseCaseOKOutput {
    public let santanderKeyDetail: SantanderKeyDetailResultRepresentable
}
