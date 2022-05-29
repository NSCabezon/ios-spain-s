//
//  PersonalManagerReactiveDataRepositoryswift.swift
//  SANLibraryV3
//
//  Created by Boris Chirino Fernandez on 7/2/22.
//
import SANLegacyLibrary
import OpenCombine
import CoreDomain
import Foundation

struct PersonalManagerReactiveDataRepository {
    struct GenericError: LocalizedError {
        var errorDescription: String?
    }
    private let bsanWallManager: BSANManagersManager
    
    init(bsanManager: BSANManagersManager) {
        self.bsanWallManager = bsanManager
    }
}

extension PersonalManagerReactiveDataRepository: PersonalManagerReactiveRepository {
    func loadClick2Call() -> AnyPublisher<ClickToCallRepresentable, Error> {
        return Future<ClickToCallRepresentable, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    let result = try bsanWallManager.loadClick2Call()
                    guard let response = try result.getResponseData() else {
                        throw GenericError(errorDescription: try result.getErrorMessage())
                    }
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadClick2Call(_ reason: String?) -> AnyPublisher<ClickToCallRepresentable, Error> {
        return Future<ClickToCallRepresentable, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    let result = try bsanWallManager.loadClick2Call(reason)
                    guard let response = try result.getResponseData() else {
                        throw GenericError(errorDescription: try result.getErrorMessage())
                    }
                    promise(.success(response))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func loadPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        return Future<[PersonalManagerRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    let result = try bsanWallManager.loadManagers()
                    guard let response = try result.getResponseData() else {
                        throw GenericError(errorDescription: try result.getErrorMessage())
                    }
                    promise(.success(response.managerList))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getPersonalManagers() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        return Future<[PersonalManagerRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    let result = try bsanWallManager.getManagers()
                    guard let response = try result.getResponseData() else {
                        throw GenericError(errorDescription: try result.getErrorMessage())
                    }
                    promise(.success(response.managerList))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
