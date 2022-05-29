//
//  SpainOnboardingRepository.swift
//  Account
//
//  Created by José Norberto Hidalgo Romero on 7/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import OpenCombine
import SANLegacyLibrary

public struct SpainOnboardingRepository: OnboardingRepository {
    private let pgManager: BSANPGManager
    
    public init(pgManager: BSANPGManager) {
        self.pgManager = pgManager
    }
     
    public func getOnboardingInfo() -> AnyPublisher<OnboardingInfoRepresentable, Error> {
        guard let gpData = try? pgManager.getGlobalPosition().getResponseData()
        else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<OnboardingInfoRepresentable, Error> { promise in
            Async.main {
                do {
                    let userInfo = OnboardingInfo(identifier: gpData.userId ?? "",
                                                  name: gpData.clientNameWithoutSurname ?? "")
                    promise(.success(userInfo))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

public struct OnboardingInfo: OnboardingInfoRepresentable {
    public let identifier: String
    public let name: String
}
