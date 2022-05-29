//
//  PrivateMenuEventsRepository.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 24/2/22.
//
import CoreDomain
import OpenCombine
import Foundation

public class DefaultPrivateMenuEventsRepository: PrivateMenuEventsRepository {
    private var subject = PassthroughSubject<PrivateMenuEvents, Never>()
    public init() {}
}

public extension DefaultPrivateMenuEventsRepository {
    func eventsPublisher() -> AnyPublisher<PrivateMenuEvents, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func didShowMenu() {
        subject.send(.didShowMenu)
    }
    
    func willShowMenu(highlightedOption: PrivateMenuOptions?) {
        subject.send(.willShowMenu(highlightedOption))
    }
    
    public func didHideMenu() {
        subject.send(.didHideMenu)
    }
}
