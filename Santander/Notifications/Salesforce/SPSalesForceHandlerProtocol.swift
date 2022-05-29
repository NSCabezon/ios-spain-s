//
//  SalesforceHandlerProtocol.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 14/04/2021.
//

import CoreFoundationLib
import RetailLegacy
import ESCommons

protocol SPSalesForceHandlerProtocol: NotificationServiceProtocol, InboxMessagesManager {
    func setSubscriberKey()
}
