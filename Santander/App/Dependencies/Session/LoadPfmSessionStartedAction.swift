//
//  LoadPfmSessionStartedAction.swift
//  Santander
//
//  Created by Hernán Villamil on 14/10/21.
//

import CoreFoundationLib

final class LoadPfmSessionStartedAction: SessionStartedAction {
    let dependenciesResolver: DependenciesResolver
    var action: () -> Void {
        return { [weak self] in
            let pfmHelper = self?.dependenciesResolver.resolve(for: PfmHelperProtocol.self)
            pfmHelper?.execute()
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
