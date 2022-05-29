//
//  MockPersonalManagerNotificationReactiveRepository.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreDomain
import OpenCombine

final class MockPersonalManagerNotificationReactiveRepository: PersonalManagerNotificationReactiveRepository {
    func getManagerNotificationsInfo() -> AnyPublisher<PersonalManagerNotificationRepresentable, Error> {
        return Just(MockPersonalManagerNotificationRepresentable())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private struct MockPersonalManagerNotificationRepresentable: PersonalManagerNotificationRepresentable {
    var unreadMessages: String = ""
}
