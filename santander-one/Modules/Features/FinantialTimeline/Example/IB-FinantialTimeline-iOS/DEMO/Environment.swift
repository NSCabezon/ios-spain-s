//
//  Environment.swift
//  TimeLine - DEMO
//
//  Created by José Carlos Estela Anguita on 18/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import FinantialTimeline

struct TimeLineURL {
    static let host: URL? = URL(string: "http://test/timeline/")
    static let configurationURL: URL? = URL(string: "http://test/timeline/configuration")
    static let angularURL: URL? = URL(string: "https://ib-finantialtimeline-angular.develop.blue4sky.com/IB-FinantialTimeline-Angular")
}

struct Environment {
    
    static func setupNativeTimeLine(for authorization: Authorization, currencySymbols: [String: String], delegate: TimeLineDelegate, language: String) {
        guard let host = TimeLineURL.host, let configurationURL = TimeLineURL.configurationURL else { return }
        TimeLine.setup(configuration: .native(host: host, configurationURL: configurationURL, currencySymbols: currencySymbols, authorization: authorization, timeLineDelegate: delegate, actions: getTimeLineActions()), restClient: DemoRestClient())
    }
    
    static func setupHybridTimeLine(for authorization: Authorization, url: URL, language: String) {
        TimeLine.setup(configuration: .hybrid(url: url, authorization: authorization, language: language))
    }
    
    static func getTimeLineActions() -> [CTAAction] {
        let actions: [PublicCTA] = [.init(reference: "goToAccounts"),
                                    .init(reference: "goToCards")]

        return actions
    }
}
