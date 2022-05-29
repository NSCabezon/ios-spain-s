//
//  PullOffersRepositoryProtocol.swift
//  Repository
//
//  Created by Juan Carlos López Robles on 11/16/20.
//

import Foundation


public protocol PullOffersRepositoryProtocol {
    func setup() -> RepositoryResponse<Void>
    func reset() -> RepositoryResponse<Void>
    func getPullOffersInfo(userId: String, offerId: String) -> RepositoryResponse<PullOffersInfoDTO>
    func removePullOffersInfo(userId: String, offerId: String) -> RepositoryResponse<Void>
    
    func expireOffer(userId: String, offerId: String) -> RepositoryResponse<Void>
    func visitOffer(userId: String, offerId: String) -> RepositoryResponse<Void>
    
    func setRule(identifier: String, isValid: Bool) -> RepositoryResponse<Void>
    func isValidRule(identifier: String) -> RepositoryResponse<Bool>
    func setOffer(location: String, offerId: String?) -> RepositoryResponse<Void>
    func getOffer(location: String) -> RepositoryResponse<String>
    func removeOffer(location: String) -> RepositoryResponse<Void>
    func removePullOffersData() -> RepositoryResponse<Void>
    var visitedLocations: Set<String> { get set }
    var sessionDisabledOffers: Set<String> { get set }
}
