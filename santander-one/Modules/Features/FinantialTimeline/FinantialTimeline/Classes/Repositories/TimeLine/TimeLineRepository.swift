//
//  TimeLineRepository.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 01/07/2019.
//

import Foundation

protocol TimeLineRepository {
    func fetchComingTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void)
    func fetchPreviousTimeLineEvents(date: Date, offset: String?, completion: @escaping (Result<TimeLineEvents, Error>) -> Void)
    func deleteEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void)
    func createCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void)
    func updateCustomEvent(_ event: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void)
    func fetchTimeLineEventDetail(for identifier: String, completion: @escaping (Result<TimeLineEvent, Error>) -> Void)
    func loadCustomEvents(offset: String?, completion: @escaping (Result<PeriodicEvents, Error>) -> Void)
    func createAlertforEvent(_ event: TimeLineEvent, type: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func deleteAlertforEvent(_ event: TimeLineEvent, completion: @escaping (Result<Bool, Error>) -> Void)
    func deleteCustomEvent(id: String, completion: @escaping (Result<Bool, TimeLineRepositoryError>) -> Void)
    func getMasterCustomEvent(code: String, completion: @escaping (Result<PeriodicEvent, Error>) -> Void)
    func fetchCards(completion: @escaping (Result<CadsList, Error>) -> Void)
    func fetchAccounts(completion: @escaping (Result<AccountList, Error>) -> Void)
    func getDate(completion: @escaping (Result<Date, Error>) -> Void)
}
