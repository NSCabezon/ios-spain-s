//
//  SavingsOtherOperativesViewModel.swift
//  SavingProducts

import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import MachO
import UIOneComponents

enum SavingsOtherOperativesState: State {
    case idle
    case loadActions((actions: [SavingAction], sectionTitle: String))
    case loadDebitActions
    case loadPrepaidActions
    case loadCreditActions
}

final class SavingsOtherOperativesViewModel: DataBindable {
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SavingsOtherOperativesDependenciesResolver
    var arrayActionsInSection: [SavingAction] = []
    private var savingProduct: SavingProductRepresentable? {
            dataBinding.get().map{$0}
    }
    private let configurationSubject = PassthroughSubject<SavingsOtherOperativesState, Never>()
    let elementsPublisher = PassthroughSubject<[OneProductMoreOptionsAction], Never>()

    init(dependencies: SavingsOtherOperativesDependenciesResolver) {
        self.dependencies = dependencies
    }

    func viewDidLoad() {
        bindSavingOtherOperatives()
    }

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    func finishAndDismissView() {
        coordinator.dismiss()
    }

}

private extension SavingsOtherOperativesViewModel {
    var coordinator: SavingsOtherOperativesCoordinator {
        return dependencies.resolve()
    }

    var getSavingProductOptionsUsecase: GetSavingProductOptionsUseCase {
        return dependencies.external.resolve()
    }
}


private extension SavingsOtherOperativesViewModel {

    func bindSavingOtherOperatives() {
        guard let savingProduct = savingProduct,
            let contractNumber = savingProduct.contractRepresentable?.contractNumber,
            let savingsType = savingProduct.accountSubType
            else { return }
        self.getSavingProductOptionsUsecase
            .fetchOtherOperativesOptions(contractNumber: contractNumber, savingsProductType: savingsType)
                .map { [unowned self] options in
                    self.classifyActionsBySection(savingProduct: savingProduct, options: options)
                }
                .map { [unowned self] actions in
                    self.getNormalizedActions(savingActions: actions)
                }
                .receive(on: Schedulers.main)
                .sink {[unowned self] savingActions in
                    self.elementsPublisher.send(savingActions)
                }.store(in: &self.subscriptions)
    }


    func classifyActionsBySection(savingProduct: SavingProductRepresentable,
                                  options: [SavingProductOptionRepresentable]) -> [SavingAction] {
        return options.map { optionRepresentable in
            return SavingAction(savingProduct: savingProduct,
                                type: optionRepresentable.type,
                                title: optionRepresentable.title,
                                iconName: optionRepresentable.imageName,
                                section: optionRepresentable.otherOperativesSection ?? .settings,
                                viewType: nil,
                                action: nil, // TODO: configure action
                                isDisabled: false)
        }
    }

    func getNormalizedActions(savingActions: [SavingAction]) -> [OneProductMoreOptionsAction] {
        var optionActionsArray = [OneProductMoreOptionsAction]()
        for section in SavingsActionSection.allCases {
            let elementsInSection = savingActions.filter { $0.section == section }
            guard elementsInSection.count > 0 else { continue }
            let elements = elementsInSection.map { action in
                return OneProductMoreOptionsActionElement(title: action.title ,
                                                          iconName: action.iconName,
                                                          isDisabled: action.isDisabled,
                                                          accessibilitySuffix: "_\(action.type.accessibilityIdentifier ?? "")",
                                                          action: { [weak self] in
                    self?.coordinator.goToSavingsAction(type: action.type)
                                                           })
            }
            let newOptionsAction = OneProductMoreOptionsAction(sectionTitle: section.title ?? "",
                                                               accessibilitySuffix: section.accessibilityIdentifier,
                                                               elements: elements)
            optionActionsArray.append(newOptionsAction)
        }
        return optionActionsArray
    }
}

extension SavingsOtherOperativesViewModel: OneProductMoreOptionsViewModelProtocol {}

// MARK: - Analytics
extension SavingsOtherOperativesViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: SavingMoreOptionsPage {
        SavingMoreOptionsPage()
    }
}
