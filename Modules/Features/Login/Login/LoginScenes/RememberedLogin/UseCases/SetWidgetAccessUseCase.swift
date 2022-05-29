//
//  SetWidgetAccessUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/10/20.
//

import Foundation
import CoreFoundationLib
import ESCommons

class SetWidgetAccessUseCase: UseCase<SetWidgetAccessInput, Void, StringErrorOutput> {
    private var compilation: SpainCompilationProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.compilation = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: SetWidgetAccessInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let query = KeychainQuery(service: compilation.service,
                                  account: compilation.quickbalance,
                                  accessGroup: compilation.sharedTokenAccessGroup,
                                  data: NSNumber(value: requestValues.isWidgetEnabled))
        do {
            try KeychainWrapper().save(query: query)
            return UseCaseResponse.ok()
        } catch {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
    }
}

struct SetWidgetAccessInput {
    let isWidgetEnabled: Bool
}
