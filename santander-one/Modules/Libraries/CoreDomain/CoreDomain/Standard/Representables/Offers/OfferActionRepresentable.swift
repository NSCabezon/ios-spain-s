//
//  OfferActionRepresentable.swift
//  CoreDomain
//
//  Created by Cristobal Ramos Laina on 29/11/21.
//

public protocol OfferActionRepresentable {
    var type: String { get }
    func getDeserialized() -> String
}
