//
//  SantanderLogoViewModel.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation
import CoreFoundationLib

struct SantanderLogoViewModel {
    private let semanticSegmentType: SemanticSegmentTypeEntity
    
    init(semanticSegmentType: SemanticSegmentTypeEntity) {
        self.semanticSegmentType = semanticSegmentType
    }
    
    func logo() -> String {
        switch self.semanticSegmentType {
        case .spb: return "logoPbLogin"
        case .retail: return "logoSanLogin"
        case .select: return "logoSelectLogin"
        case .universitarios: return "logoSmartBankLogin"
        }
    }
}
