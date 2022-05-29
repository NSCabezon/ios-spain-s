//
//  PTDeeplinkVerifierProtocol.swift
//  Commons
//
//  Created by Erik Nascimento on 28/07/21.
//

import Foundation

public protocol PTDeeplinkVerifierProtocol: AnyObject {
    func verifyOffer(entity: OfferEntity, completion: (Bool) -> Void)
    func isCodeValid(code: String) -> Bool
    func isPagaSimplesCode(code: String) -> Bool
    func isChangeCreditCardLimit(code: String) -> Bool
}
