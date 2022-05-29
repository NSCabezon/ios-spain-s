//
//  GetHomeTipsUseCase.swift
//  Menu
//
//  Created by alvola on 16/12/2021.
//

import Foundation
import OpenCombine
import CoreFoundationLib

public protocol GetHomeTipsCountUseCase {
    func filterHomeTipsElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never>
}

struct DefaultGetHomeTipsCountUseCase {
    private let homeTipsRepository: HomeTipsRepository
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.homeTipsRepository = dependencies.external.resolve()
    }
}

extension DefaultGetHomeTipsCountUseCase: GetHomeTipsCountUseCase {
    func filterHomeTipsElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return homeTipsRepository
            .getHomeTipsCount()
            .map({ tipsCount in
                self.filterOptions(elementsToFilter,
                                 hasHomeTips: tipsCount > 0)
            })
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetHomeTipsCountUseCase {
    func filterOptions(_ options: [[PublicMenuElementRepresentable]], hasHomeTips: Bool) -> [[PublicMenuElementRepresentable]] {
        return options.compactMap { (config) in
            config.compactMap {
                return self.filterCommercialSegment($0, hasHomeTips)
            }
        }
    }
    
    func filterCommercialSegment(_ option: PublicMenuElementRepresentable, _ hasHomeTips: Bool) -> PublicMenuElementRepresentable? {
        var editableOption = option
        if option.top?.action == .goToHomeTips {
            editableOption.top = hasHomeTips ? option.top : nil
        }
        if option.bottom?.action == .goToHomeTips {
            editableOption.bottom = hasHomeTips ? option.bottom : nil
        }
        return editableOption
    }
}
