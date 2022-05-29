//
//  TimeSelectorDependenciesResolver.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import UI
import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain

protocol TimeSelectorDependenciesResolver {
    var external: TimeSelectorExternalDependenciesResolver { get }
    func resolve() -> TimeSelectorViewModel
    func resolve() -> TimeSelectorViewController
    func resolve() -> TimeSelectorCoordinator
    func resolve() -> DataBinding
}

extension TimeSelectorDependenciesResolver {
    
    func resolve() -> TimeSelectorViewController {
        return TimeSelectorViewController(dependencies: self)
    }
    
    func resolve() -> TimeSelectorViewModel {
        return TimeSelectorViewModel(dependencies: self)
    }
}
