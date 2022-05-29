//
//  GetPersonalManagerUseCaseSpy.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import OpenCombine
import PrivateMenu

class GetPersonalManagerUseCaseSpy: GetPersonalManagerUseCase {
    var fetchPersonalManagerCalled: Bool = false
    var fetchServiceStatusCalled: Bool = false
    var unreadNotificationCalled: Bool = false
    
    func fetchPersonalManager() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        fetchPersonalManagerCalled = true
        return Just([MockPersonalManager()]).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchServiceStatus() -> AnyPublisher<PersonalManagerServicesStatusRepresentable, Never> {
        fetchServiceStatusCalled = true
        let personalManagerServicesStatus = MockPersonalManagerServicesStatus(
            managerWallEnabled: false,
            managerWallVersion: 1,
            enableManagerNotifications: false,
            videoCallEnabled: false
        )
        return Just(personalManagerServicesStatus).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
    
    func unreadNotification() -> AnyPublisher<Bool, Never> {
        unreadNotificationCalled = true
        return Just(false).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}
