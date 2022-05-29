//
//  Dependencies.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/07/2019.
//

import Foundation
import CoreFoundationLib

class Dependencies {
    
    // MARK: - Public
    
   var configuration: Configuration?
    
    // MARK: - Shared
    
    lazy var restClient: RestClient = {
       return IntelligentBankingRestClient()
    }()
    lazy var textsEngine: TextsEngine = {
        return TextsEngine(baseDate: TimeLine.dependencies.configuration?.currentDate ?? Date(),
                           locale: Locale(identifier: TimeLine.dependencies.configuration?.language ?? Locale.current.languageCode ?? "en"))
    }()
    lazy var ctasEngine: CTAEngine = {
        return CTAEngine(locale: Locale(identifier: TimeLine.dependencies.configuration?.language ?? Locale.current.languageCode ?? "en"))
    }()
    lazy var merchantIconEngine: MerchantIconEngine = {
       return MerchantIconEngine()
    }()
    lazy var configurationEngine: ConfigurationEngine = {
        return ConfigurationEngine(configurationRepository: configurationRepository, textsEngine: textsEngine, ctasEngine: ctasEngine, merchantIconEngine: merchantIconEngine)
    }()
    
    // MARK: - Computed
    
    var dependenciesResolver: DependenciesResolver {
        guard let dependenciesResolver = configuration?.dependenciesResolver else { fatalError("You have to call `TimeLine.setup()` before doing anything") }
        return dependenciesResolver
    }
    
    var configurationRemoteDataSource: ConfigurationDataSource {
        guard let url = configuration?.native?.configurationURL, let authorization = configuration?.authorization else { fatalError("You have to call `TimeLine.setup()` before doing anything") }
        return ConfigurationRemoteDataSource(url: url, restClient: restClient, authorization: authorization)
    }
    var timeLineRepository: TimeLineRepository {
        guard let host = configuration?.native?.host, let authorization = configuration?.authorization else { fatalError("You have to call `TimeLine.setup()` before doing anything") }
        return TimeLineADNRepository(host: host, restClient: restClient, authorization: authorization)
    }
    var configurationRepository: ConfigurationRepository {
        return ConfigurationApiRepository(remoteDataSource: configurationRemoteDataSource)
    }
}

extension Dependencies {
    func getStrategy() -> TimeLineStrategy? {
        guard let type = configuration?.type else { return nil }
        switch type {
        case .native:
            return TimeLineNativeStrategy()
        case .hybrid:
            return TimeLineHybridStrategy()
        }
    }
}
