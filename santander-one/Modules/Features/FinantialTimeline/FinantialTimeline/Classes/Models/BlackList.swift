//
//  BlackList.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 12/12/2019.
//

import Foundation

public struct BlackList: Codable {
    var onlyFuture: Bool?
    var accountCodes: [Product]?
    var cardCodes: [Product]?
    var eventTypeCodes: [TimeLineConfiguration.Text]?
    var maxNumberOfMonths: Int?
    var minNumberOfMonths: Int?
}

extension BlackList {
    func getRequestParams() -> [String: Any]? {
        var params: [String: Any] = [:]
        
        if let data = getAccountCodes() {
            params["blacklistedAccountIds"] = data
        }
        
        if let data = getCardCodes() {
            params["blacklistedCardIds"] = data
        }
        
        if let data = getEventTypeCodes() {
            params["blacklistedEventTypes"] = data
        }
        
        if let data = getDateRange() {
            params["dateRange"] = data
        }
        
        return params.isEmpty ? nil : params
    }
    
    private func getAccountCodes() -> [String]? {
        guard let list = accountCodes else { return nil }
        var returnList = [String]()
        list.forEach({returnList.append($0.accountCode ?? "")})
        return returnList
    }
    
    private func getCardCodes() -> [String]? {
        guard let list = cardCodes else { return nil }
        var returnList = [String]()
        list.forEach({returnList.append($0.cardCode ?? "")})
        return returnList
    }
    
    private func getEventTypeCodes() -> [String]? {
        guard let list = eventTypeCodes else { return nil }
        var returnList = [String]()
        list.forEach({returnList.append($0.transactionType )})
        return returnList
    }
    
    private func getDateRange() -> [String: String]? {
        let today = TimeLine.dependencies.configuration?.currentDate ?? Date()
        var params = [String: String]()
        if let months = minNumberOfMonths {
            let minDate = today.adding(.month, value: months)
            params["minDate"] = minDate.string(format: .api)
        }
        
        if let months = maxNumberOfMonths {
            let maxDate = today.adding(.month, value: months)
            params["maxDate"] = maxDate.string(format: .api)
        }
        
         return params.isEmpty ? nil : params
    }
}
