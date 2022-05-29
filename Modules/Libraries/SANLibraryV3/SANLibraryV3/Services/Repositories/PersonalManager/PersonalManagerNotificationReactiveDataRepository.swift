//
//  PersonalManagerNotificationReactiveDataRepository.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 11/2/22.
//

import SANLegacyLibrary
import OpenCombine
import CoreDomain
import CoreFoundationLib

struct PersonalManagerNotificationReactiveDataRepository {
    private let bsanNotificationManager: BSANManagerNotificationsManager

    init(bsanNotificationManager: BSANManagerNotificationsManager) {
        self.bsanNotificationManager = bsanNotificationManager
    }
}

extension PersonalManagerNotificationReactiveDataRepository: PersonalManagerNotificationReactiveRepository {
    func getManagerNotificationsInfo() -> AnyPublisher<PersonalManagerNotificationRepresentable, Error> {
        return Future<PersonalManagerNotificationRepresentable, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    let response = try bsanNotificationManager.getManagerNotificationsInfo()
                    let adaptedResponse: Result<PersonalManagerNotificationRepresentable, Error>
                    = try BSANResponseConverter.convert(response: response)
                    switch adaptedResponse {
                    case .success(let success):
                        promise(.success(success))
                    case .failure(let error):
                        promise(.failure(RepositoryError.error(error)))
                    }
                } catch {
                    promise(.failure(RepositoryError.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
