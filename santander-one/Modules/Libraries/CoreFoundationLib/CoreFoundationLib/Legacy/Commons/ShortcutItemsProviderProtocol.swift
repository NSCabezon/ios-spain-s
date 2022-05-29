//
//  ShortcutItemsProviderProtocol.swift
//  Commons
//
//  Created by José María Jiménez Pérez on 27/4/21.
//

public protocol ShortcutItemsProviderProtocol {
    func getShortcutItems() -> [ShortcutItemProtocol]
}

public protocol ShortcutItemProtocol {
    var localizedTitleKey: String { get }
    var icon: UIApplicationShortcutIcon { get }
    var deepLink: DeepLinkEnumerationCapable { get }
}
