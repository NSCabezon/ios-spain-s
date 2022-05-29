 //
//  ShoppingMapDependenciesResolver.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

 import UI
 import OpenCombine
 import CoreDomain
 import CoreFoundationLib

protocol CardShoppingMapDependenciesResolver {
    var external: CardShoppingMapExternalDependenciesResolver { get }
    func resolve() -> CardShoppingMapViewController
    func resolve() -> CardShoppingMapViewModel
    func resolve() -> CardShoppingMapCoordinator
    func resolve() -> DataBinding
}

extension CardShoppingMapDependenciesResolver {
    func resolve() -> CardShoppingMapViewController {
        return CardShoppingMapViewController(dependencies: self)
    }
    
    func resolve() -> CardShoppingMapViewModel {
        return CardShoppingMapViewModel(dependencies: self)
    }
}
