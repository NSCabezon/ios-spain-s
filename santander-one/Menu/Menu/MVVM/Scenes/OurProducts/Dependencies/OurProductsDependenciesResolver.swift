//
//  OurProductsDependenciesResolver.swift
//  Menu
//
//  Created by alvola on 01/12/2021.
//

import Foundation
import CoreFoundationLib

protocol OurProductsDependenciesResolver {
    var external: OurProductsExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
