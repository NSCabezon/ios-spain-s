//
//  PrivateMenuActionsRepository.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 24/2/22.
//

import OpenCombine
import CoreDomain

public enum PrivateMenuEvents: State {
    case didShowMenu
    case willShowMenu(PrivateMenuOptions?)
    case didHideMenu
}

public protocol PrivateMenuEventsRepository {
    func eventsPublisher() -> AnyPublisher<PrivateMenuEvents, Never>
    func didShowMenu()
    func willShowMenu(highlightedOption: PrivateMenuOptions?)
    func didHideMenu()
}
