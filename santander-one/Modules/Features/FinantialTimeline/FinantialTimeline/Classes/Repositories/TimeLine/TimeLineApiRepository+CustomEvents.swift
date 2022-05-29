//
//  File.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 11/10/2019.
//

import Foundation

enum TimeLineRepositoryError: Error {
    case KOResponse
    case serviceFailed
}

extension TimeLineApiRepository {
    
    func createCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/periodic",
            method: .post,
            headers: authorization.headers(),
            params: .params(params: event.dictionary ?? [:], encoding: .json)
        ) {
            switch $0 {
            case .success: completion($0.decode())
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func loadCustomEvents(offset: String?, completion: @escaping (Result<PeriodicEvents, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: offset ?? "/timeline/periodics/0",
            method: .get,
            headers: authorization.headers(),
            params: .none
        ) {
            switch $0 {
            case .success: completion($0.decode())
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func deleteCustomEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/periodic/\(id)",
            method: .delete,
            headers: authorization.headers(),
            params: .none
        ) {
            switch $0.asString() {
            case .success(let result):
                if result == "OK" {
                    completion(.success(true))
                } else {
                    completion(.failure(.KOResponse))
                }
            case .failure: completion(.failure(.serviceFailed))
            }
        }
    }
    
    func updateCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        guard let id = event.id else { return }
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/periodic/\(id)",
            method: .put,
            headers: authorization.headers(),
            params: .params(params: event.dictionary ?? [:], encoding: .json)
        ) {
            switch $0 {
            case .success: completion($0.decode())
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func getMasterCustomEvent(code: String, completion: @escaping (Result<PeriodicEvent, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/periodic/\(code)",
            method: .get,
            headers: authorization.headers(),
            params: .none
        ) {
            switch $0 {
            case .success: completion($0.decode())
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
}
