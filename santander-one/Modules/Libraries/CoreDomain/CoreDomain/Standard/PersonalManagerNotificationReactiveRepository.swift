//
//  PersonalManagerNotificationReactiveRepository.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 11/2/22.
//
import OpenCombine

public protocol PersonalManagerNotificationReactiveRepository {
    func getManagerNotificationsInfo() -> AnyPublisher<PersonalManagerNotificationRepresentable, Error>
}
