//

import Foundation
import CoreFoundationLib

class UpdateUserVisualizationsUseCase: UseCase<UpdateUserVisualizationsUseCaseInput, UpdateUserVisualizationsUseCaseOkOutput, UpdateUserVisualizationsUseCaseErrorOutput> {
    
    override public func executeUseCase(requestValues: UpdateUserVisualizationsUseCaseInput) throws -> UseCaseResponse<UpdateUserVisualizationsUseCaseOkOutput, UpdateUserVisualizationsUseCaseErrorOutput> {
        let userPref = update(userPref: requestValues.userPref, withModules: requestValues.modules, withBoxes: requestValues.boxes)
        return UseCaseResponse.ok(UpdateUserVisualizationsUseCaseOkOutput(userPref: userPref))
    }
    
    private func update(userPref: UserPref, withModules modules: [UserVisualizationModule], withBoxes boxes: [UserVisualizationBox]) -> UserPref {
        
        func update(userPrefsBox box: inout PGBoxDTO, withItems items: [UserVisualizationItem]) {
            items.enumerated().forEach { offset, element in
                if var boxItem = box.getItem(withIdentifier: element.itemIdentifier) {
                    boxItem.isVisible = element.isVisible
                    boxItem.order = offset
                    box.set(item: boxItem, withIdentifier: element.itemIdentifier)
                }
            }
        }
        
        for module in modules {
            switch module.itemIdentifier {
            case PGModuleDTO.Constants.pfmModule:
                userPref.userPrefDTO.pgUserPrefDTO.pfmModule.isVisible = module.isVisible
            case PGModuleDTO.Constants.yourMoneyModule:
                userPref.userPrefDTO.pgUserPrefDTO.yourMoneyModule.isVisible = module.isVisible
            default: break
            }
        }
        
        for box in boxes {
            switch box.type {
            case .accounts:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.accountsBox, withItems: box.items)
            case .notManagedPortfolios:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox, withItems: box.items)
            case .managedPortfolios:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.portfolioManagedsBox, withItems: box.items)
            case .cards:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.cardsBox, withItems: box.items)
            case .deposits:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.depositsBox, withItems: box.items)
            case .loans:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.loansBox, withItems: box.items)
            case .stocks:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.stocksBox, withItems: box.items)
            case .pensions:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.pensionssBox, withItems: box.items)
            case .funds:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.fundssBox, withItems: box.items)
            case .insuranceSavings:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.insuranceSavingsBox, withItems: box.items)
            case .insuranceProtection:
                update(userPrefsBox: &userPref.userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox, withItems: box.items)
            }
        }
        
        return userPref
    }
}

struct UpdateUserVisualizationsUseCaseInput {
    let userPref: UserPref
    let modules: [UserVisualizationModule]
    let boxes: [UserVisualizationBox]
}

struct UpdateUserVisualizationsUseCaseOkOutput {
    let userPref: UserPref
}

class UpdateUserVisualizationsUseCaseErrorOutput: StringErrorOutput {
}
