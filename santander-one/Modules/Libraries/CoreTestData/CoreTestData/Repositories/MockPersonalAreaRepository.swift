//
//  MockPersonalAreaRepository.swift
//  CoreTestData
//
//  Created by Jose Camallonga on 10/2/22.
//

import Foundation
import CoreDomain
import OpenCombine

public struct MockPersonalAreaRepository: PersonalAreaRepository {
    public init() {}
    
    public func fetchDigitalProfilePercentage() -> AnyPublisher<DigitalProfilePercentageRepresentable, Error> {
        return Just(DigitalProfilePercentage())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func fetchCompleteDigitalProfileInfo() -> AnyPublisher<DigitalProfileRepresentable?, Never> {
        return Just(DigitalProfile()).eraseToAnyPublisher()
    }
}

public struct DigitalProfilePercentage: DigitalProfilePercentageRepresentable {
    public init() {}
    
    public var percentage: Double {
        return 45.0
    }
    
    public var notConfiguredItems: [DigitalProfileElemProtocol] {
        return []
    }
}

private extension MockPersonalAreaRepository {
    struct DigitalProfile: DigitalProfileRepresentable {
        var percentage: Double = 45.0
        var category: DigitalProfileEnum = .cadet
        var configuredItems: [DigitalProfileElemProtocol] = []
        var notConfiguredItems: [DigitalProfileElemProtocol] = []
        var username: String = ""
        var userLastname: String = ""
        var userImage: Data?
    }
}
