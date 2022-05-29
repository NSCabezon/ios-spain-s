//
//  TimeLineApiRepository+Alerts.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 11/10/2019.
//

import Foundation

extension TimeLineApiRepository {
    

    
    func createAlertforEvent(_ event: TimeLineEvent, type: String, completion: @escaping (Result<Bool, Error>) -> Void) {
                        
        let koError = NSError(domain: "timelineApiRepository.restclient", code: 0, userInfo: [NSLocalizedDescriptionKey: "The services returned KO"])
        restClient.request(host: host.absoluteString,
                           path: "/timeline/alerts",
                           method: .post,
                           headers: authorization.headers(),
                           params: .params(params: ["eventId": event.identifier, "type": type], encoding: .json)
                           ) {
                            switch $0.asString() {
                            case .success(let result):
                                if result == "OK" {
                                    completion(.success(true))
                                } else {
                                    completion(.failure(koError))
                                }
                            case .failure(let error):completion(.failure(error))
                            }
            }
    }
    
    func deleteAlertforEvent(_ event: TimeLineEvent, completion: @escaping (Result<Bool, Error>) -> Void) {
        let koError = NSError(domain: "timelineApiRepository.restclient", code: 0, userInfo: [NSLocalizedDescriptionKey: "The services returned KO"])
         restClient.request(host: host.absoluteString,
                            path: "/timeline/alerts/\(event.identifier)",
                            method: .delete,
                            headers: authorization.headers(),
                            params: .none) {
                             switch $0.asString() {
                             case .success(let result):
                                 if result == "OK" {
                                     completion(.success(true))
                                 } else {
                                     completion(.failure(koError))
                                 }
                             case .failure(let error):completion(.failure(error))
                             }
             }
    }
    
}
