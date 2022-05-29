//
//  CardDetailDependenciesResolver.swift
//  Cards
//
//  Created by Gloria Cano López on 17/2/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol CardDetailDependenciesResolver {
    var external: CardDetailExternalDependenciesResolver { get }
    func resolve() -> CardDetailViewModel
    func resolve() -> CardDetailViewController
    func resolve() -> CardDetailCoordinator
    func resolve() -> GetCardDetailUseCase
    func resolve() -> ChangeAliasCardUseCase
    func resolve() -> DataBinding
}

extension CardDetailDependenciesResolver {
    func resolve() -> CardDetailViewController {
        return CardDetailViewController(dependencies: self)
    }
    func resolve() -> CardDetailViewModel {
        return CardDetailViewModel(dependencies: self)
    }
    func resolve() -> GetCardDetailUseCase {
        return DefaultGetCardDetailUseCase(dependencies: self)
    }
    func resolve() -> ChangeAliasCardUseCase {
        DefaultChangeAliasCardUseCase(dependencies: self)
    }
}
