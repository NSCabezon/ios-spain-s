//
//  GetPersonalManagerUseCase.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 27/12/21.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetPersonalManagerUseCase {
    func fetchPersonalManager() -> AnyPublisher<[PersonalManagerRepresentable], Error>
    func fetchServiceStatus() -> AnyPublisher<PersonalManagerServicesStatusRepresentable, Never>
    func unreadNotification() -> AnyPublisher<Bool, Never>
}

struct DefaultGetPersonalManagerUseCase {
    init() {}
}

extension DefaultGetPersonalManagerUseCase: GetPersonalManagerUseCase {
    func fetchPersonalManager() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchServiceStatus() -> AnyPublisher<PersonalManagerServicesStatusRepresentable, Never> {
        return Empty()
            .eraseToAnyPublisher()
    }

    func unreadNotification() -> AnyPublisher<Bool, Never> {
        return Empty()
            .eraseToAnyPublisher()
    }
}
