//
//  TimeSelectorUseCase.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol TimeSelectorUseCase {
    
}

struct DefaultTimeSelectorUseCase {
    
    init(dependencies: TimeSelectorDependenciesResolver) {
        
    }
}

extension DefaultTimeSelectorUseCase: TimeSelectorUseCase {
    
}
