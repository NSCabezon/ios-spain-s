//
//  CardBlockModifierProtocol.swift
//  Cards
//
//  Created by Laura González on 31/05/2021.
//

import Foundation

public protocol CardBlockModifierProtocol {
    var showCommentReason: Bool { get }
    func isCardBlockAvailable() -> Bool
}
