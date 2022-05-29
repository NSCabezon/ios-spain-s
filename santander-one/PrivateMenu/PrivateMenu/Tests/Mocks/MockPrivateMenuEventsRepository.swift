//
//  MockPrivateMenuEventsRepository.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 3/5/22.
//

import CoreDomain
import CoreFoundationLib
import OpenCombine

final class MockPrivateMenuEventsRepository: PrivateMenuEventsRepository {
    func eventsPublisher() -> AnyPublisher<PrivateMenuEvents, Never> {
        let event: PrivateMenuEvents = .didShowMenu
        return Just(event)
            .eraseToAnyPublisher()
    }
    
    func didShowMenu() {}
    
    func willShowMenu(highlightedOption: PrivateMenuOptions?) {}
    
    func didChangeAvatarImage(_ image: Data) {}
    
    func didHideMenu() {}
}
