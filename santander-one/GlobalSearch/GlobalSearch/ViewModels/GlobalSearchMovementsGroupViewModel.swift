//
//  GlobalSearchMovementsGroupViewModel.swift
//  GlobalSearch
//
//  Created by Ernesto Fernandez Calles on 23/3/21.
//

import Foundation

final class GlobalSearchMovementsGroupViewModel {
    var productAlias: String?
    var productIdentifier: String?
    var movements: [GlobalSearchResultMovementViewModel] = []
    
    func hasAccountMovements() -> Bool {
        
        if let movement = movements.first, movement.resultType == .account {
            return true
        }
        
        return false
    }
    
    func hasCardMovements() -> Bool {
        
        if let movement = movements.first, movement.resultType == .card {
            return true
        }
        
        return false
    }
}
