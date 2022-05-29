//
//  LocalPullOffersVarsModifierProtocol.swift
//  RetailLegacy
//
//  Created by Laura Gonzalez Salvador on 28/10/21.
//

import Foundation

public protocol LocalPullOffersVarsModifierProtocol {
    func getClientSegmentName(completion: @escaping (String) -> Void)
}
