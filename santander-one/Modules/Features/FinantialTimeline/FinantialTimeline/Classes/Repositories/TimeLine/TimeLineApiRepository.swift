//
//  TimeLineApiRepository.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/07/2019.
//

import Foundation

class TimeLineApiRepository: TimeLineRepository {
    
    internal let host: URL
    internal let restClient: RestClient
    internal let authorization: Authorization
    
    init(host: URL, restClient: RestClient, authorization: Authorization) {
        self.host = host
        self.restClient = restClient
        self.authorization = authorization
    }
    
    func fetchComingTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {        
        restClient.request(
            host: host.absoluteString,
            path: offset ?? "/timeline/\(date.string(format: .yyyyMMdd))\(Utils.getTimeZone())/coming/0",
            method: getFetchEnventAFMethod(),
            headers: authorization.headers(),
            params: getBlackListParams()
        ) {
            completion($0.decode())
        }
    }
    
    func fetchPreviousTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: offset ?? "/timeline/\(date.string(format: .yyyyMMdd))\(Utils.getTimeZone())/previous/0",
            method: getFetchEnventAFMethod(),
            headers: authorization.headers(),
            params: getBlackListParams()
        ) {
            completion($0.decode())
        }
    }
    
    func fetchTimeLineEventDetail(for identifier: String, completion: @escaping (Result<TimeLineEvent, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/event/\(identifier)/\(Utils.getTimeZone())",
            method: .get,
            headers: authorization.headers(),
            params: .none
        ) {
            completion($0.decode())
        }
    }
    
    func fetchCards(completion: @escaping (Result<CadsList, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/me/cards",
            method: .get,
            headers: authorization.headers(),
            params: .none
        ) {
            completion($0.decode())
        }
    }
    
    func fetchAccounts(completion: @escaping (Result<AccountList, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/me/accounts",
            method: .get,
            headers: authorization.headers(),
            params: .none
        ) {
            completion($0.decode())
        }
    }
    
    func deleteEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/\(id)",
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
    
    func getBlackListParams() -> RestClientParams {
        guard let blackList = SecureStorageHelper.getBlackList(),
            let params =  blackList.getRequestParams() else { return .none }
        return .params(params: params, encoding: .json)
    }
    
    func getFetchEnventAFMethod() -> RestClientHTTPMethod {
        guard SecureStorageHelper.getBlackList() != nil else { return .get}
        return .post
    }
    
    func getDate(completion: @escaping (Result<Date, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline/now\(Utils.getTimeZone())/coming/0",
            method: getFetchEnventAFMethod(),
            headers: authorization.headers(),
            params: getBlackListParams()
        ) {
            completion($0.decode())
        }
    }
}



