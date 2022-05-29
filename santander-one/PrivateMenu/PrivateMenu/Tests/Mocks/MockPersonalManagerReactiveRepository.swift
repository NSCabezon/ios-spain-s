//
//  MockPersonalManagerReactiveRepository.swift
//  CoreTestData
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreDomain
import OpenCombine

public final class MockPersonalManagerReactiveRepository: PersonalManagerReactiveRepository {
    public func getPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadClick2Call() -> AnyPublisher<ClickToCallRepresentable, Error> {
        return Just(MockClickToCallRepresentable())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func loadClick2Call(_ reason: String?) -> AnyPublisher<ClickToCallRepresentable, Error> {
        return Just(MockClickToCallRepresentable())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private struct MockClickToCallRepresentable: ClickToCallRepresentable {
    var contactPhone: String = ""
}
