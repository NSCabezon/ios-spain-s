//
//  WallanagerReactiveRepository.swift
//  SANLibraryV3
//
//  Created by Boris Chirino Fernandez on 7/2/22.
//

import OpenCombine

public protocol PersonalManagerReactiveRepository {
    func getPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error>
    func loadPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error>
    func loadClick2Call() -> AnyPublisher<ClickToCallRepresentable, Error>
    func loadClick2Call(_ reason: String?) -> AnyPublisher<ClickToCallRepresentable, Error>
}
