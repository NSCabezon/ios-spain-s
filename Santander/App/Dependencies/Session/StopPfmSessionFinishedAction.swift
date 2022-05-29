//
//  StopPfmSessionFinishedAction.swift
//  Santander
//
//  Created by Hernán Villamil on 14/10/21.
//

import CoreFoundationLib

final class StopPfmSessionFinishedAction: SessionFinishedAction {
    let dependenciesResolver: DependenciesResolver
    var action: (SessionFinishedReason) -> Void {
        return { [weak self] reason in
            let pfmHelper = self?.dependenciesResolver.resolve(for: PfmHelperProtocol.self)
            pfmHelper?.finishSession(reason)
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
