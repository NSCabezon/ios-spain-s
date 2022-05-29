//
//  OneTransferExternalDependenciesResolver.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 4/1/22.
//

import Foundation
import UI
 
public extension OneTransferHomeExternalDependenciesResolver where Self: OneFavouritesListExternalDependenciesResolver {
    func resolve() -> OneFavouritesListExternalDependenciesResolver {
        return self
    }
}
