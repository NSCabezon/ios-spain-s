//
//  MockOnboardingRepository.swift
//  CoreTestData
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import Foundation
import OpenCombine
import CoreDomain

public struct MockOnboardingRepository: OnboardingRepository {
    public struct OnboardingInfo: OnboardingInfoRepresentable {
        public let identifier: String
        public let name: String
    }
    
    public init() {}
    
    public func getOnboardingInfo() -> AnyPublisher<OnboardingInfoRepresentable, Error> {
        return Just(OnboardingInfo(identifier: "12345678", name: "Little Alice"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
