//
//  Environment.swift
//  TimeLine - PRE
//
//  Created by José Carlos Estela Anguita on 18/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import FinantialTimeline

struct TimeLineURL {
    static let host: URL? = URL(string: "https://ib-finantialtimeline-backend.develop.blue4sky.com")
    static let configurationURL: URL? = URL(string: "https://fileserver.blue4sky.com/intelligentbanking/timeline/setup.json")
    static let angularURL: URL? = URL(string: "https://ib-finantialtimeline-angular.develop.blue4sky.com/IB-FinantialTimeline-Angular.html")
}

struct Environment {
    
    static func setupNativeTimeLine(for authorization: Authorization, currencySymbols: [String: String], delegate: TimeLineDelegate, language: String) {
        guard let host = TimeLineURL.host, let configurationURL = TimeLineURL.configurationURL else { return }
        let configuration: Configuration = .native(host: host,
                                                   configurationURL: configurationURL,
                                                   currencySymbols: currencySymbols,
                                                   authorization: authorization,
                                                   timeLineDelegate: delegate,
                                                   actions: getTimeLineActions(),
                                                   language: language)
        TimeLine.setup(configuration: configuration)
    }
    
    static func setupHybridTimeLine(for authorization: Authorization, url: URL, language: String) {
        TimeLine.setup(configuration: .hybrid(url: url, authorization: authorization, language: language))
    }
    
    static func getTimeLineActions() -> [PublicCTA] {
        let actions: [PublicCTA] = [.init(reference: "goToAccounts"),
                                    .init(reference: "goToCards")]

        return actions
    }
}
