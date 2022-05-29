//
//  InternalTransferSummaryViewModel.swift
//  Account
//
//  Created by crodrigueza on 4/3/22.
//

import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

struct InternalTransferSummaryAdditionalFeeAlertConfiguration {
    let additionalFeeKey: String
    let additionalFeeLinkKey: String?
    let additionalFeeLink: String?
    let additionalFeeIconKey: String
}

enum InternalTransferSummaryState: State {
    case idle
    case loaded
    case headerLoaded(AmountRepresentable)
    case summaryItemsLoaded([OneListFlowItemViewModel])
    case alertItemLoaded(InternalTransferSummaryAdditionalFeeAlertConfiguration)
    case sharingLoaded([InternalTransferSummarySharingButtonItem])
    case footerLoaded(OneFooterNextStepViewModel)
}

final class InternalTransferSummaryViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: InternalTransferSummaryDependenciesResolver
    private lazy var modifier: InternalTransferSummaryModifierProtocol = dependencies.external.resolve()
    private var sharingBuilder: InternalTransferSummarySharingBuilder!
    private var footerBuilder: InternalTransferSummaryFooterBuilder!
    private let stateSubject = CurrentValueSubject<InternalTransferSummaryState, Never>(.idle)
    var state: AnyPublisher<InternalTransferSummaryState, Never>
    @BindingOptional var operativeData: InternalTransferOperativeData!
    
    init(dependencies: InternalTransferSummaryDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }

    func viewDidLoad() {
        loadHeader()
        loadSummaryItems()
        loadAlertItem()
        loadSharing()
        loadFooter()
        trackScreen()
    }

    func close() {
        coordinator.dismiss()
    }

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    func didTapOnToggleSummaryButton() {
        trackEvent(.seeSummary)
    }
}

private extension InternalTransferSummaryViewModel {
    var coordinator: InternalTransferOperativeCoordinator {
        return dependencies.resolve()
    }
    
    func loadHeader() {
        guard let amount = operativeData.amount else {  return }
        stateSubject.send(.headerLoaded(amount))
    }
    
    func loadSummaryItems() {
        let builder = InternalTransferHeaderSummaryBuilder(dependencies: dependencies,
                                                           operativeData: operativeData)
        builder.addSourceAccount()
        builder.addAmount()
        builder.addExchangeRate()
        builder.addSendDate()
        builder.addDestinationAccount()
        stateSubject.send(.summaryItemsLoaded(builder.build()))
    }
    
    func loadAlertItem() {
        guard let origin = operativeData.originAccount,
              let destination = operativeData.destinationAccount,
              modifier.freeTransferFor(originAccount: origin, destinationAccount: destination, date: operativeData.issueDate) == false else { return }
        let configuration = InternalTransferSummaryAdditionalFeeAlertConfiguration(additionalFeeKey: modifier.additionalFeeKey, additionalFeeLinkKey: modifier.additionalFeeLinkKey, additionalFeeLink: modifier.additionalFeeLink, additionalFeeIconKey: modifier.additionalFeeIconKey)
        stateSubject.send(.alertItemLoaded(configuration))
    }

    func loadSharing() {
        sharingBuilder = InternalTransferSummarySharingBuilder(subscriptions: &anySubscriptions)
        sharingBuilder.addDownloadPDF { [weak self] in self?.goToDownloadPDF() }
        sharingBuilder.addShareImage { [weak self] in self?.goToShareImage() }
        stateSubject.send(.sharingLoaded(sharingBuilder.build()))
    }
    
    func loadFooter() {
        footerBuilder = InternalTransferSummaryFooterBuilder(subscriptions: &anySubscriptions)
        footerBuilder.addSendMoney { [weak self] in self?.goToSendMoneyHome() }
        footerBuilder.addGlobalPosition { [weak self] in self?.goToGlobalPosition() }
        footerBuilder.addHelp { [weak self] in self?.showHelp() }
        stateSubject.send(.footerLoaded(footerBuilder.build()))
    }

    func goToDownloadPDF() {
        coordinator.goToDownloadPDF()
        trackEvent(.downladPDF)
    }

    func goToShareImage() {
        coordinator.goToShareImage()
        trackEvent(.shareImage)
    }
    
    func goToSendMoneyHome() {
        coordinator.goToSendMoneyHome()
    }
    
    func goToGlobalPosition() {
        coordinator.goToGlobalPosition()
    }
    
    func showHelp() {
        coordinator.showSuccessOpinator()
    }
}

// MARK: - Subscriptions
private extension InternalTransferSummaryViewModel { }

// MARK: - Publishers
private extension InternalTransferSummaryViewModel { }

// MARK: Analytics
extension InternalTransferSummaryViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: InternalTransferThankYouPage {
        InternalTransferThankYouPage()
    }
}
