//
//  Configuration.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/07/2019.
//

import Foundation
import CoreFoundationLib

enum TimeLineType {
    case hybrid(HybridConfiguration)
    case native(NativeConfiguration)
}

struct HybridConfiguration {
    let url: URL
}

struct NativeConfiguration {
    let host: URL
    let configurationURL: URL
    let currencySymbols: [String: String]
    weak var timeLineDelegate: TimeLineDelegate?
    let actions: [PublicCTA]
    
    func symbol(for key: String) -> String? {
        return currencySymbols.first(where: { $0.key.uppercased() == key.uppercased() })?.value
    }
    
    func symbols() -> String {
        return currencySymbols.description
    }
}

public class Configuration {
    
    let language: String
    let type: TimeLineType
    let authorization: Authorization
    let dependenciesResolver: DependenciesResolver
    var currentDate: Date?
    var native: NativeConfiguration? {
        guard case let .native(configuration) = type else { return nil }
        return configuration
    }
    var hybrid: HybridConfiguration? {
        guard case let .hybrid(configuration) = type else { return nil }
        return configuration
    }
    
    init(type: TimeLineType, authorization: Authorization, dependenciesResolver: DependenciesResolver, language: String = Locale.current.languageCode ?? "en") {
        self.type = type
        self.authorization = authorization
        self.language = language
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    /// The time line public configuration for native mode
    ///
    /// - Parameters:
    ///   - host: The host of the service
    ///   - configurationURL: The url of the timeline configuration file
    ///   - currencySymbols: A dictionary with the currencyCode : currencySymbol. i.e ["EUR": "€"]
    ///   - timeLineActionDelegate: A delegate of the type TimeLineCTAActionDelegate
    ///   - actions: An array of TimeLineAction elements
    ///   - authorization: The authorization method to use
    ///   - language: The language the componenet is going to be based on
    /// - Returns: The configuration entity
    public static func native(host: URL, configurationURL: URL, currencySymbols: [String: String],
                              authorization: Authorization, timeLineDelegate: TimeLineDelegate?,
                              actions: [PublicCTA], dependenciesResolver: DependenciesResolver,
                              language: String = Locale.current.languageCode ?? "en") -> Configuration {
        let configuration = Configuration(
            type: .native(NativeConfiguration(host: host,
                                              configurationURL: configurationURL,
                                              currencySymbols: currencySymbols,
                                              timeLineDelegate: timeLineDelegate,
                                              actions: actions)),
            authorization: authorization,
            dependenciesResolver: dependenciesResolver,
            language: language
        )
        return configuration
    }
    
    /// The time line public configuration for hybrid mode
    ///
    /// - Parameters:
    ///   - url: The timeline web url
    ///   - authorization: The authorization method to use
    ///   - language: The language the componenet is going to be based on
    /// - Returns: The configuration entity
    public static func hybrid(url: URL, authorization: Authorization, dependenciesResolver: DependenciesResolver, language: String = Locale.current.languageCode ?? "en") -> Configuration {
        let configuration = Configuration(
            type: .hybrid(HybridConfiguration(url: url)),
            authorization: authorization,
            dependenciesResolver: dependenciesResolver,
            language: language
        )
        return configuration
    }
}
