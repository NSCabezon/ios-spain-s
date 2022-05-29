//
//  Pusher.swift
//  Santander Pusher
//
//  Created by José Carlos Estela Anguita on 4/5/21.
//  Copyright © 2021 Experis Solutions. All rights reserved.
//

import Foundation
import PerfectNotifications

enum App {
    case spain
    case portugal
    case poland
    
    var appIDPrefix: String {
        switch self {
        case .spain:
            return "es.bancosantander.apps.ios"
        case .portugal:
            return ""
        case .poland:
            return ""
        }
    }
}

enum Compilation {
    case pre
    case intern
    case dev
    
    var appIDSuffix: String {
        switch self {
        case .pre:
            return "pre"
        case .intern:
            return "intern"
        case .dev:
            return "dev"
        }
    }
}

enum PushType {
    case otp(String)
    case ecommerce(String)
    case cardLandingPush(subscriber: String, transactionInfo: CardLandingPush, alertInfo: CardAlertInfo)
    case accountLandingPush(subscriber: String, transactionInfo: AccountLandingPush, alertInfo: AccountAlertInfo)
    case mediaUrl(url: String)
    case offerNavigation(offer: String)
    
    var items: [APNSNotificationItem] {
        switch self {
        case .otp(let value):
            return [
                .mutableContent,
                .customPayload("otp", value),
                .customPayload("tp_device_id", "29036876"),
                .customPayload("tp_id", "79891224")
            ]
        case .ecommerce(let value):
            return [
                .mutableContent,
                .customPayload("otp", value),
                .customPayload("tp_device_id", "29036876"),
                .customPayload("tp_id", "79891224"),
                .customPayload("open_type", "ecommerce")
            ]
        case .cardLandingPush(let subscriber, let transactionInfo, let alertInfo):
            let jsonEncoder = JSONEncoder()
            let decodedTransactionInfo = try! jsonEncoder.encode(transactionInfo)
            let decodedAlertInfo = try! jsonEncoder.encode(alertInfo)
            return [
                .customPayload("openType", "cardTransaction"),
                .customPayload("subscriber", subscriber),
                .customPayload("transactionInfo", String(data: decodedTransactionInfo, encoding: .utf8)!),
                .customPayload("alertInfo", String(data: decodedAlertInfo, encoding: .utf8)!)
            ]
        case .accountLandingPush(let subscriber, let transactionInfo, let alertInfo):
            let jsonEncoder = JSONEncoder()
            let decodedTransactionInfo = try! jsonEncoder.encode(transactionInfo)
            let decodedAlertInfo = try! jsonEncoder.encode(alertInfo)
            return [
                .customPayload("openType", "accountTransaction"),
                .customPayload("subscriber", subscriber),
                .customPayload("transactionInfo", String(data: decodedTransactionInfo, encoding: .utf8)!),
                .customPayload("alertInfo", String(data: decodedAlertInfo, encoding: .utf8)!)
            ]
        case .mediaUrl(let url):
            return [
                .customPayload("_mediaUrl", url),
                .mutableContent
            ]
        case .offerNavigation(let offer):
            return [
                .customPayload("openType", "normal"),
                .customPayload("navigation", "offer"),
                .customPayload("id", offer)
            ]
        }
    }
}

struct PusherConfiguration {
    let app: App
    let compilation: Compilation
    let version: String
}

struct Pusher {
    
    let configuration: PusherConfiguration
    var appID: String {
        return configuration.app.appIDPrefix + "." + configuration.compilation.appIDSuffix + "." + configuration.version
    }
    
    init(configuration: PusherConfiguration) {
        self.configuration = configuration
        NotificationPusher.addConfigurationAPNS(
            name: appID,
            production: false,
            keyId: "B92Q4NPS99",
            teamId: "JFX6PVNK48",
            privateKeyPath: Bundle.main.path(forResource: "AuthKey_B92Q4NPS99", ofType: "p8") ?? ""
        )
    }
    
    func send(to deviceTokens: String..., title: String, body: String, type: PushType) {
        let notification = NotificationPusher(apnsTopic: appID)
        notification.pushAPNS(
            configurationName: appID,
            deviceTokens: deviceTokens,
            notificationItems: type.items + [.alertTitle(title), .alertBody(body), .sound("default")]
        ) { response in
            print("Notification response: \(response)")
            exit(1)
        }
    }
}
