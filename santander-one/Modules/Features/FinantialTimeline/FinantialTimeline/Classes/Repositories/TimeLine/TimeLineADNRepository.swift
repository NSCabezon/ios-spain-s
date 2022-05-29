//
//  TimeLineADNRepository.swift
//  FinantialTimeline
//
//  Created by Jose Carlos Estela Anguita on 20/01/2020.
//

import Foundation

private struct TimeLineADNEvents: Codable {
    
    let data: TimeLineEvents
    let timestamp: Date
    let links: [String: [String: String]]
    
    enum CodingKeys: String, CodingKey {
        case data, timestamp, links = "_links"
    }
}

extension TimeLineADNEvents: DateParseable {
    
    static var formats: [String: String] {
        return [
            "timestamp": "yyyy-MM-dd HH:mm:ss.SSS",
            "data.movements.transaction.date": "yyyy-MM-dd"
        ]
    }
}

class TimeLineADNRepository: TimeLineRepository {
    
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
            path: "/timeline",
            method: .get,
            headers: headers(for: authorization),
            params: comingParams(date: date, offset: offset)
        ) {
            completion(self.comingAdnEventsToEvents(result: $0.decode()))
        }
    }
    
    func fetchPreviousTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void) {
        restClient.request(
            host: host.absoluteString,
            path: "/timeline",
            method: .get,
            headers: headers(for: authorization),
            params: previousParams(date: date, offset: offset)
        ) {
            completion(self.previousAdnEventsToEvents(result: $0.decode()))
        }
    }
    
    func deleteEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        
    }
    
    func createCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        
    }
    
    func updateCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void) {
        
    }
    
    func fetchTimeLineEventDetail(for identifier: String, completion: @escaping (Result<TimeLineEvent, Error>) -> Void) {
        
    }
    
    func loadCustomEvents(offset: String?, completion: @escaping (Result<PeriodicEvents, Error>) -> Void) {
        
    }
    
    func createAlertforEvent(_ event: TimeLineEvent, type: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func deleteAlertforEvent(_ event: TimeLineEvent, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func deleteCustomEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void) {
        
    }
    
    func getMasterCustomEvent(code: String, completion: @escaping (Result<PeriodicEvent, Error>) -> Void) {
        
    }
    
    func fetchCards(completion: @escaping (Result<CadsList, Error>) -> Void) {
        
    }
    
    func fetchAccounts(completion: @escaping (Result<AccountList, Error>) -> Void) {
        
    }
    
    func getDate(completion: @escaping (Result<Date, Error>) -> Void) {
        completion(.success(Date()))
    }
    
    // MARK: - Private
    
    private func headers(for authorization: Authorization) -> [String: String] {
        let otherHeaders = [
            "X-Santander-Channel": "RML",
            "X-ClientId": "MULMOV"
        ]
        return authorization.headers().merging(otherHeaders, uniquingKeysWith: { $1 })
    }
    
    private func previousParams(date: Date, offset: String?) -> RestClientParams {
        let basicParams: [String: Any] = [
            "date": date.string(format: .yyyyMMddWithHyphenSeparator),
            "limit": 15,
            "direction": "backward"
        ]
        return offsetParams(with: basicParams, offset: offset)
    }
    
    private func comingParams(date: Date, offset: String?) -> RestClientParams {
        let basicParams: [String: Any] = [
            "date": date.string(format: .yyyyMMddWithHyphenSeparator),
            "limit": 15,
            "direction": "forward"
        ]
        return offsetParams(with: basicParams, offset: offset)
    }
    
    private func offsetParams(with basicParams: [String: Any], offset: String?) -> RestClientParams {
        // Gets the offset if exist with the following format `/timeline?date=XXX&offset=XXXX` and extract the `offset`
        let offsetParam: [String : Any] = {
            guard
                let unwrappedOffset = offset,
                let url = URL(string: host.absoluteString + unwrappedOffset),
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let offset = components.queryItems?.first(where: { $0.name == "offset" })?.value
            else {
                return [:]
            }
            return ["offset": offset]
        }()
        return .params(
            params: basicParams.merging(offsetParam, uniquingKeysWith: { $1 }),
            encoding: .url(destination: .url)
        )
    }
    
    private func previousAdnEventsToEvents(result: Result<TimeLineADNEvents, Error>) -> Result<TimeLineEvents, Error> {
        self.adnToEvents(result: result) { adnEvents in
            var events = adnEvents.data
            events.currentDate = adnEvents.timestamp
            let offset = adnEvents.links["prev"]?["href"]
            events.offset = offset
            return events
        }
    }
    
    private func comingAdnEventsToEvents(result: Result<TimeLineADNEvents, Error>) -> Result<TimeLineEvents, Error> {
        self.adnToEvents(result: result) { adnEvents in
            var events = adnEvents.data
            events.currentDate = adnEvents.timestamp
            let offset = adnEvents.links["next"]?["href"]
            events.offset = offset
            return events
        }
    }
    
    private func adnToEvents(result: Result<TimeLineADNEvents, Error>, conversion: @escaping (TimeLineADNEvents) -> TimeLineEvents) -> Result<TimeLineEvents, Error> {
        switch result {
        case .failure(let error):
            return .failure(error)
        case .success(let adnEvents):
            return .success(conversion(adnEvents))
        }
    }
}
