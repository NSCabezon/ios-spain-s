//
//  DeleteScheduledTransferResumeStepPresenter.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 20/7/21.
//

import Operative
import CoreFoundationLib

protocol DeleteScheduledTransferResumeStepPresenterProtocol: OperativeSummaryPresenterProtocol {
    func close()
}
    
final class DeleteScheduledTransferResumePresenter {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeSummaryViewProtocol?
    var isBackButtonEnabled = true
    var isCancelButtonEnabled = true
    var container: OperativeContainerProtocol?
    var number = 0
    var shouldShowProgressBar = false
    private var shareCapableOperative: ShareOperativeCapable? {
        self.container?.operative as? ShareOperativeCapable
    }
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    private lazy var operativeData: DeleteScheduledTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getShareableInfo() -> String {
        return("Shared info")
    }
}

extension DeleteScheduledTransferResumePresenter: OperativeSummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.operativeData.bankIconURL = self.bankIconPath()
        let builder = DeleteScheduledTransferResumeBuilder(operativeData: self.operativeData)
        builder.addAmount()
        builder.addConcept()
        builder.addOriginAccount()
        builder.addOrderType()
        builder.addBeneficiary()
        builder.addDestinationCountry()
        builder.addPeridiocity()
        builder.addEmissionDate()
        builder.addShareAction(withAction: share)
        // footer
        builder.addNewSend(withAction: self.goToNewSend)
        builder.addGoPG(withAction: self.goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addHelpImprove(withAction: self.goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.view?.setupStandardBody(
            withItems: viewModel.bodyItems,
            actions: viewModel.bodyActionItems,
            collapsableSections: .defaultCollapsable(visibleSections: 4)
        )
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension DeleteScheduledTransferResumePresenter {
    func goToNewSend() {
        self.container?.save(DeleteScheduledTransferOperative.FinishingOption.home)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(DeleteScheduledTransferOperative.FinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        trackEvent(.feedback, parameters: trackerParams)
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
    
    func share() {
        trackEvent(.share, parameters: trackerParams)
        shareCapableOperative?.getShareView(completion: { [weak self] result in
            switch result {
            case .success((let shareView, let view)):
                guard
                    let self = self,
                    let shareView = shareView,
                    let containerView = view
                else { return }
                self.container?.coordinator.share(self, type: .image(shareView, containerView))
            case .failure:
                return
            }
        })
    }

    func bankIconPath() -> String? {
        guard let accountEntity = self.operativeData.account,
              let ibanEntity = self.operativeData.detail?.iban,
              let entityCode = ibanEntity.ibanElec.substring(4, 8),
              let countryCode = accountEntity.contryCode,
              let baseUrl = baseURLProvider.baseURL
        else { return nil}

        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var trackerParams: [String: String]? {
        let parameterKey = TrackerDimension.progTransferType.key
        var parameter = [parameterKey: ""]
        if let isTransferPeriodic = self.operativeData.order?.isPeriodic {
            let transferType = isTransferPeriodic ? "periodica" : "diferida"
            parameter.updateValue(transferType, forKey: parameterKey)
        }
        return parameter
    }
}

extension DeleteScheduledTransferResumePresenter: DeleteScheduledTransferResumeStepPresenterProtocol {
    func close() {
        self.container?.save(DeleteScheduledTransferOperative.FinishingOption.operativeFinished)
        self.container?.stepFinished(presenter: self)
    }
}

extension DeleteScheduledTransferResumePresenter: Shareable {}

extension DeleteScheduledTransferResumePresenter: AutomaticScreenActionTrackable {
    var trackerPage: DeleteScheduledTransferResumePage {
        DeleteScheduledTransferResumePage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    func getTrackParameters() -> [String: String]? {
        trackerParams
    }
}
