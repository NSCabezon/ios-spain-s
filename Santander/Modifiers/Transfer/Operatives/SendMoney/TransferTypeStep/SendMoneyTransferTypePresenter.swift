//
//  SendMoneyTransferTypePresenter.swift
//  Santander
//
//  Created by Angel Abad Perez on 25/11/21.
//

import Operative
import CoreFoundationLib
import CoreDomain
import TransferOperatives

protocol SendMoneyTransferTypePresenterProtocol: OperativeStepPresenterProtocol {
    var view: SendMoneyTransferTypeView? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectClose()
    func didSelectTransferType(at index: Int)
    func didSelectOptionFromCostView(at index: Int)
    func didPressedFloatingButton()
    func didTapTooltip()
    func getSubtitleInfo() -> String
    func getStepOfSteps() -> [Int]
}

final class SendMoneyTransferTypePresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyTransferTypeView?
    private lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private lazy var transferTypes: [SendMoneyTransferTypeFee]? = {
        guard let specialPricesOutput = self.operativeData.specialPricesOutput as? SendMoneyTransferTypeUseCaseOkOutput
        else { return nil }
        return specialPricesOutput.fees
    }()
    private lazy var instantMaxAmount: AmountRepresentable? = {
        guard let specialPricesOutput = self.operativeData.specialPricesOutput as? SendMoneyTransferTypeUseCaseOkOutput
        else { return nil }
        return specialPricesOutput.instantMaxAmount
    }()
    private lazy var transferDateType: SendMoneyDateTypeViewModel? = {
        return self.operativeData.transferDateType
    }()
    private lazy var sendMoneyModifierProtocol: SendMoneyModifierProtocol? = {
        self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }()
    private lazy var sendMoneyUseCaseProvider: SendMoneyUseCaseProviderProtocol = {
        return self.dependenciesResolver.resolve()
    }()
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SendMoneyTransferTypePresenter: SendMoneyTransferTypePresenterProtocol {
    func viewDidLoad() {
        let viewModel = self.mapToRadioButtonsContainerViewModel(from: self.transferTypes ?? [])
        self.view?.showTransferTypes(viewModel: viewModel)
        self.trackerManager.trackScreen(screenId: self.trackerPage.page,
                                        extraParameters: [(self.operativeData.type == .national ? Constants.Tracker.transferCountryKey : Constants.Tracker.transferTypeKey) :
                                                            self.operativeData.type.trackerName])
    }
    
    func didSelectBack() {
        self.container?.back()
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func didSelectTransferType(at index: Int) {
        guard let transferType = transferTypes?[index] else { return }
        self.operativeData.selectedTransferType = transferType
    }
    
    func didSelectOptionFromCostView(at index: Int) {
        self.selectTransferType(at: index)
        self.view?.closeBottomSheetView()
    }
    
    func didPressedFloatingButton() {
        guard self.sendMoneyModifierProtocol?.isEnabledSimulationTransfer == false && self.transferDateType != .now else {
            self.validate()
            return
        }
        self.container?.stepFinished(presenter: self)
    }
    
    func didTapTooltip() {
        self.trackEvent(.clickTooltip, parameters: [Constants.Tracker.transferTypeKey: self.operativeData.type.trackerName])
    }
    
    func getSubtitleInfo() -> String {
        self.container?.getSubtitleInfo(presenter: self) ?? ""
    }
    
    func getStepOfSteps() -> [Int] {
        self.container?.getStepOfSteps(presenter: self) ?? []
    }
}

private extension SendMoneyTransferTypePresenter {
    enum Constants {
        enum Tracker {
            static let transferCountryKey: String = "transfer_country"
            static let transferTypeKey: String = "transfer_type"
        }
    }
    
    func mapToRadioButtonsContainerViewModel(from transferTypes: [SendMoneyTransferTypeFee]) -> SendMoneyTransferTypeRadioButtonsContainerViewModel {
        let radioButtonViewModels = transferTypes.compactMap { self.mapToRadioButtonViewModel(from: $0) }
        return SendMoneyTransferTypeRadioButtonsContainerViewModel(selectedIndex: self.getSelectedIndex(),
                                                                   viewModels: radioButtonViewModels)
    }
    
    func mapToRadioButtonViewModel(from transferType: SendMoneyTransferTypeFee) -> SendMoneyTransferTypeRadioButtonViewModel? {
        guard let type = transferType.type as? SpainTransferType else { return nil }
        let accessibilitySuffix = getAccessibilitySuffixForTransferType(type)
        let accessibilityLabelSuffix = accessibilitySuffix.replace("Delivery", "")
        let oneRadioButtonViewModel = OneRadioButtonViewModel(status: .inactive,
                                                              titleKey: type.title ?? "",
                                                              subtitleKey: type.subtitle ?? "",
                                                              bottomSheetView: self.getCostView(for: transferType),
                                                              accessibilitySuffix: accessibilitySuffix,
                                                              titleAccessibilityLabel: "voiceover\(accessibilityLabelSuffix)Position",
                                                              tooltipAccessibilityLabel: localized("voiceover\(accessibilityLabelSuffix)HelpInfo"))
        let feeViewModel = SendMoneyTransferTypeFeeViewModel(amount: transferType.fee,
                                                             status: .inactive,
                                                             accessibilitySuffix: accessibilitySuffix)
        return SendMoneyTransferTypeRadioButtonViewModel(oneRadioButtonViewModel: oneRadioButtonViewModel,
                                                         feeViewModel: feeViewModel,
                                                         commissionsInfoKey: type.commissionsInfo ?? "",
                                                         accessibilitySuffix: accessibilitySuffix)
    }

    func getAccessibilitySuffixForTransferType(_ transferType: SpainTransferType) -> String {
        switch transferType {
        case .standard: return AccessibilitySendMoneyTransferType.RadioButtons.standardSuffix
        case .immediate: return AccessibilitySendMoneyTransferType.RadioButtons.immediateSuffix
        case .urgent: return AccessibilitySendMoneyTransferType.RadioButtons.expressDeliverySuffix
        }
    }
    
    func getSelectedIndex() -> Int {
        guard let selectedTransferTypeFee = self.operativeData.selectedTransferType,
              let selectedType = selectedTransferTypeFee.type as? SpainTransferType,
              let selectedFee = selectedTransferTypeFee.fee?.value
        else { return .zero }
        return transferTypes?.firstIndex(where: { transferTypeFee in
            guard let type = transferTypeFee.type as? SpainTransferType,
                  let fee = transferTypeFee.fee?.value else { return false }
            return type == selectedType && fee == selectedFee
        }) ?? .zero
    }
    
    func getCostView(for transferType: SendMoneyTransferTypeFee) -> SendMoneyTransferTypeCostView? {
        guard let type = transferType.type as? SpainTransferType else { return nil }
        let costView = SendMoneyTransferTypeCostView()
        costView.setViewModel(SendMoneyTransferTypeCostViewModel(type: type, instantMaxAmount: self.instantMaxAmount))
        return costView
    }
    
    func selectTransferType(at index: Int) {
        self.view?.selectTransferType(at: index)
    }
    
    func getValidationInput() -> TransferTypeValidationUseCaseInput? {
        guard let originAccount = self.operativeData.selectedAccount,
              let destinationIBAN = self.operativeData.destinationIBANRepresentable,
              let amount = self.operativeData.amount,
              let selectedTransferType = self.operativeData.selectedTransferType?.type as? SpainTransferType else { return nil }
        return TransferTypeValidationUseCaseInput(
            type: self.operativeData.type,
            subType: selectedTransferType,
            originAccount: originAccount,
            destinationIBAN: destinationIBAN,
            amount: amount,
            concept: self.operativeData.description,
            name: self.operativeData.destinationName,
            alias: self.operativeData.destinationAlias,
            saveFavorites: self.operativeData.saveToFavorite,
            beneficiaryMail: nil,
            maxAmount: self.instantMaxAmount,
            checkEntityAdhered: selectedTransferType == .immediate,
            isUrgent: selectedTransferType == .urgent)
    }
    
    func validate() {
        guard let input = self.getValidationInput()
        else {
            self.container?.stepFinished(presenter: self)
            return
        }
        self.view?.showLoadingView()
        let useCase = self.sendMoneyUseCaseProvider.getTransferTypeValidationUseCase(input: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.view?.hideLoadingView()
                self.container?.stepFinished(presenter: self)
            }
            .onError { [weak self] _ in
                self?.view?.hideLoadingView()
                self?.container?.showGenericError()
            }
    }
}

extension SendMoneyTransferTypePresenter: AutomaticScreenActionTrackable {
    var trackerPage: SendMoneyTransferTypePage {
        return SendMoneyTransferTypePage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
