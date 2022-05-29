//
//  EmitterViewModel.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import Foundation
import CoreFoundationLib

enum EmitterElementType<T> {
    case header
    case footer
    case element(T)
    case loading
}

final class EmitterViewModel {
    private let header = 0
    let emitter: EmitterEntity
    let baseUrl: String?
    var incomes: [IncomeViewModel]
    var isExpanded: Bool = false
    
    init(_ emitter: EmitterEntity, incomes: [IncomeViewModel], baseUrl: String?) {
        self.emitter = emitter
        self.incomes = incomes
        self.baseUrl = baseUrl
    }
    
    var name: String {
        return emitter.name.camelCasedString
    }
    
    var code: String {
        return emitter.code
    }
    
    var numberOfElements: Int {
        guard self.isExpanded else { return 1 }
        guard self.incomes.count > 0 else {  return 3 }
        return self.incomes.count + 2
    }
    
    private var footer: Int {
        guard self.incomes.count > 0 else { return 2 }
        return self.incomes.count + 1
    }
    
    func toggle() {
        self.isExpanded = !self.isExpanded
    }
    
    func collapsed() {
        self.isExpanded = false
    }
    
    func elementType(at position: Int) -> EmitterElementType<IncomeViewModel> {
        if position == header {
            return .header
        } else if position == footer {
            return .footer
        } else if self.incomes.count > 0 {
            return .element(self.incomes[position - 1])
        } else {
            return .loading
        }
    }
    
    var iconUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil}
        return String(format: "%@RWD/emisoras/iconos/%@.png", baseUrl, emitter.code)
    }
}

extension EmitterViewModel: Hashable {
    public static func == (lhs: EmitterViewModel, rhs: EmitterViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.emitter.name)
        hasher.combine(self.emitter.code)
    }
}
