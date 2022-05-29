//
//  CustomDeeplinkLauncher.swift
//  RetailLegacy
//
//  Created by Francisco del Real Escudero on 13/4/21.
//
import CoreFoundationLib

public protocol CustomDeeplinkLauncher {
    func launch(deeplink: String, with userInfo: [DeepLinkUserInfoKeys: String])
    func launch(deeplink: DeepLinkEnumerationCapable)
}
