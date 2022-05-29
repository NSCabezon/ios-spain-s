//
//  CardDefaultFallbackImageModifierProtocol.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 15/9/21.
//

import Foundation
import CoreFoundationLib

public protocol CardDefaultFallbackImageModifierProtocol {
    func defaultFallbackImage(card: CardEntity) -> UIImage?
    func defaultGPFallbackImage(card: CardEntity) -> UIImage?
}
