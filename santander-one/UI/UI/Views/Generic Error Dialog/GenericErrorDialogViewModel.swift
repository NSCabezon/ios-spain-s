//
//  GenericErrorDialogViewModel.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 13/04/2020.
//

import Foundation
import CoreFoundationLib

public protocol GenericDialogAddWebActionCapable {
    func isWebActionAvailable() -> Bool
    func webAction()
}

public protocol GenericDialogAddPhoneCallActionCapable {
    func isPhoneCallActionAvailable() -> Bool
    func phoneCallAction()
}

public protocol GenericDialogAddBranchLocatorActionCapable {
    func isBranchLocatorActionAvailable() -> Bool
    func branchLocatorAction()
}

public protocol GenericDialogAddGlobalPositionActionCapable {
    func isGlobalPositionActionAvailable() -> Bool
    func globalPositionAction()
}

final class GenericErrorDialogViewModelBuilder {
    private let dependenciesResolver: DependenciesResolver
    private let data: GetGenericErrorDialogDataUseCaseOkOutput
    private var coordinator: GenericErrorDialogCoordinatorProtocol {
        return self.dependenciesResolver.resolve()
    }
    var actions: [GenericErrorDialogViewModel.Action] = []
    private var addWebActionProtocol: GenericDialogAddWebActionCapable? {
        self.dependenciesResolver.resolve(forOptionalType: GenericDialogAddWebActionCapable.self)
    }
    private var addPhoneCallActionProtocol: GenericDialogAddPhoneCallActionCapable? {
        self.dependenciesResolver.resolve(forOptionalType: GenericDialogAddPhoneCallActionCapable.self)
    }
    private var addBranchLocatorActionProtocol: GenericDialogAddBranchLocatorActionCapable? {
        self.dependenciesResolver.resolve(forOptionalType: GenericDialogAddBranchLocatorActionCapable.self)
    }
    private var addGlobalPositionActionProtocol: GenericDialogAddGlobalPositionActionCapable? {
        self.dependenciesResolver.resolve(forOptionalType: GenericDialogAddGlobalPositionActionCapable.self)
    }
    
    init(dependenciesResolver: DependenciesResolver, data: GetGenericErrorDialogDataUseCaseOkOutput) {
        self.dependenciesResolver = dependenciesResolver
        self.data = data
    }
    
    func addWeb() {
        guard let customWebViewAction = self.addWebActionProtocol else {
            self.addWebViewAction()
            return
        }
        if customWebViewAction.isWebActionAvailable() {
            self.addWebViewAction()
        }
    }
    
    func addPhoneCall() {
        guard let customPhoneCallAction = self.addPhoneCallActionProtocol else {
            self.addPhoneCallAction()
            return
        }
        if customPhoneCallAction.isPhoneCallActionAvailable() {
            self.addPhoneCallAction()
        }
    }
    
    func addBranchLocator() {
        guard let customBranchLocatorAction = self.addBranchLocatorActionProtocol else {
            self.addBranchLocatorAction()
            return
        }
        if customBranchLocatorAction.isBranchLocatorActionAvailable() {
            self.addBranchLocatorAction()
        }
    }
    
    func addGlobalPosition() {
        guard let customGlobalPositionAction = self.addGlobalPositionActionProtocol else {
            self.addGlobalPositionAction()
            return
        }
        if customGlobalPositionAction.isGlobalPositionActionAvailable() {
            self.addGlobalPositionAction()
        }
    }
    
    func build() -> GenericErrorDialogViewModel {
        return GenericErrorDialogViewModel(actions: self.actions)
    }
}

private extension GenericErrorDialogViewModelBuilder {
    func addWebViewAction() {
        self.actions.append(GenericErrorDialogViewModel.Action(logo: "icnWeb", title: localized("generic_error_title_web"), description: localized("generic_error_text_web"), action: self.didSelectWebView, position: .unknown))
    }
    
    func didSelectWebView() {
        self.performModifiedActionOrDefault(modifiedAction: {
            self.addWebActionProtocol?.webAction()
        }, defaultAction: {
            self.coordinator.goToWeb(self.data.webUrl)
        })
    }
    
    func addPhoneCallAction() {
        self.actions.append(GenericErrorDialogViewModel.Action(logo: "icnPhone", title: localized("generic_error_title_customerSupport"), description: localized("generic_error_text_customerSupport", [StringPlaceholder(.phone, self.data.phone)]), action: self.didSelectPhoneCall, position: .unknown))
    }
    
    func didSelectPhoneCall() {
        self.performModifiedActionOrDefault(modifiedAction: {
            self.addPhoneCallActionProtocol?.phoneCallAction()
        }, defaultAction: {
            self.coordinator.goToPhoneCall(self.data.phone)
        })
    }
    
    func addBranchLocatorAction() {
        self.actions.append(GenericErrorDialogViewModel.Action(logo: "icnAtmGenericError", title: localized("generic_error_title_atm"), description: localized("generic_error_text_atm"), action: self.didSelectBranchLocator, position: .unknown))
    }
    
    func didSelectBranchLocator() {
        self.performModifiedActionOrDefault {
            self.addBranchLocatorActionProtocol?.branchLocatorAction()
        } defaultAction: {
            self.coordinator.goToBranchLocator()
        }
    }
    
    func addGlobalPositionAction() {
        self.actions.append(GenericErrorDialogViewModel.Action(logo: "pg", title: localized("generic_error_title_pg"), description: nil, action: self.didSelectGlobalPosition, position: .last))
    }
    
    func didSelectGlobalPosition() {
        self.performModifiedActionOrDefault {
            self.addGlobalPositionActionProtocol?.globalPositionAction()
        } defaultAction: {
            self.coordinator.goToGlobalPosition()
        }
    }
    
    func performModifiedActionOrDefault(modifiedAction: () -> Void?, defaultAction: () -> Void) {
        modifiedAction() ?? defaultAction()
    }
}

struct GenericErrorDialogViewModel {
    
    struct Action {
        
        enum Position {
            case last
            case unknown
        }
        
        let logo: String
        let title: LocalizedStylableText
        let description: LocalizedStylableText?
        let action: () -> Void
        let position: Position
    }
    
    let actions: [Action]
}
