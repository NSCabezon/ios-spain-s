//
//  SendMoneySelectAccountUseCase.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol SendMoneySelectAccountUseCase {
    
}

struct DefaultSendMoneySelectAccountUseCase {
    
    init(dependencies: SendMoneySelectAccountDependenciesResolver) {
        
    }
}

extension DefaultSendMoneySelectAccountUseCase: SendMoneySelectAccountUseCase {
    
}
