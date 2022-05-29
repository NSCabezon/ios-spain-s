//
//  GlobalSearchViewModel.swift
//  GlobalSearch
//
//  Created by Luis Escámez Sánchez on 25/02/2020.
//

import UI
import CoreFoundationLib

final class GlobalSearchViewModel {
    let movements: [GlobalSearchResultMovementViewModel]
    let actions: [GlobalSearchActionViewModel]
    let homeTips: [HelpCenterTipViewModel]
    let interestTips: [HelpCenterTipViewModel]
    let help: [TripFaqViewModel]
    let needHelpFor: [TripFaqViewModel]
    let searchTerm: String
    
    var totalResult: Int {
        return movements.count + actions.count + help.count + needHelpFor.count + homeTips.count + interestTips.count
    }
    
    init(movements: [GlobalSearchResultMovementViewModel],
         actions: [GlobalSearchActionViewModel],
         homeTips: [HelpCenterTipViewModel],
         interestTips: [HelpCenterTipViewModel],
         help: [TripFaqViewModel],
         needHelpFor: [TripFaqViewModel],
         searchTerm: String) {
        self.movements = movements
        self.actions = actions
        self.help = help
        self.needHelpFor = needHelpFor
        self.searchTerm = searchTerm
        self.homeTips = homeTips
        self.interestTips = interestTips
    }
    
    func associatedSegments() -> [GlobalSearchFilterType] {
        var segments: [GlobalSearchFilterType] = []
        if !actions.isEmpty {
            segments.append(.action)
        }
        if !movements.isEmpty {
            segments.append(.movement)
        }
        if !help.isEmpty || !needHelpFor.isEmpty || !interestTips.isEmpty {
            segments.append(.help)
        }
        if segments.count > 1 {
            segments.insert(.all, at: 0)
        }
        return segments
    }
    
    func allMovements() -> GlobalSearchMovementsGroupViewModel {
        
        let model = GlobalSearchMovementsGroupViewModel()
        model.movements.append(contentsOf: movements)
        return model
    }
    
    func groupedMovements() -> [GlobalSearchMovementsGroupViewModel] {
        
        var groupsOfMovements: [GlobalSearchMovementsGroupViewModel] = []
        
        // Create groups in date order
        for model in movements {
            
            let selectedGroup = groupsOfMovements.first {
                $0.productIdentifier == model.movement.productId
            }
            
            if let group = selectedGroup {
                group.movements.append(model)
            } else {
                
                let group = GlobalSearchMovementsGroupViewModel()
                groupsOfMovements.append(group)
                group.productAlias = model.movement.camelcasedProductAlias
                group.productIdentifier = model.movement.productId
                group.movements.append(model)
            }
        }

        // Order groups by accountType
        var orderedGroupsOfMovements: [GlobalSearchMovementsGroupViewModel] = []
        
        orderedGroupsOfMovements.append(contentsOf: groupsOfMovements.filter { (model) -> Bool in
            model.hasAccountMovements()
        })

        orderedGroupsOfMovements.append(contentsOf: groupsOfMovements.filter { (model) -> Bool in
            model.hasCardMovements()
        })
        
        return orderedGroupsOfMovements
    }
}
