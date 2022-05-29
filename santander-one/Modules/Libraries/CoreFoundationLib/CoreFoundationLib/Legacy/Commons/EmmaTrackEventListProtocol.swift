//
//  EmmaTrackEventListProtocol.swift
//  Commons
//
//  Created by Carlos Gutiérrez Casado on 25/03/2020.
//

import Foundation

public protocol EmmaTrackEventListProtocol {
    var globalPositionEventID: String { get }
    var accountsEventID: String { get }
    var cardsEventID: String { get }
    var transfersEventID: String { get }
    var billAndTaxesEventID: String { get }
    var personalAreaEventID: String { get }
    var managerEventID: String { get }
    var customerServiceEventID: String { get }
}
