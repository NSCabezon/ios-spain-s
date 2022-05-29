//
//  EmitterList.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import Foundation
import CoreFoundationLib

final class EmitterListElement {
    var emitter: EmitterEntity
    var incomes: [IncomeEntity] = []
    
    init(entity: EmitterEntity) {
        self.emitter = entity
    }
}

final class EmitterList {
    var emitters: [EmitterListElement] = []
    
    func clear() {
        self.emitters = []
    }
    
    func append(content: [EmitterEntity]) {
        let newEmitters = content.map({ EmitterListElement(entity: $0) })
        self.emitters.append(contentsOf: newEmitters)
    }
    
    func update(element: EmitterEntity, incomes: [IncomeEntity]) {
        self.emitters
            .first(where: { $0.emitter == element })?
            .incomes = incomes
    }
}
