//
//  BizumSendMoneySummaryPresenter.swift
//  Bizum
//
//  Created by Carlos Gutiérrez Casado on 18/09/2020.
//

import Foundation
import CoreFoundationLib
import Operative

protocol BizumSendMoneySummaryPresenterProtocol: OperativeSummaryPresenterProtocol {}

extension BizumSendMoneySummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

final class BizumSendMoneySummaryPresenter {
    weak var view: OperativeSummaryViewProtocol?
    var bizumView: BizumSummaryViewProtocol? {
        view as? BizumSummaryViewProtocol
    }
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: BizumSendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private var shareCapableOperative: ShareOperativeCapable? {
        self.container?.operative as? ShareOperativeCapable
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    private var shareSummaryViewModel: ShareBizumSummaryViewModel? {
        return ShareBizumSummaryViewModel(
            bizumOperativeType: operativeData.bizumOperativeType,
            bizumAmount: operativeData.bizumSendMoney?.amount,
            bizumConcept: operativeData.bizumSendMoney?.concept,
            simpleMultipleType: operativeData.simpleMultipleType,
            bizumContacts: operativeData.bizumContactEntity,
            sentDate: operativeData.operationDate,
            dependenciesResolver: self.dependenciesResolver)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumSendMoneySummaryPresenter: BizumSendMoneySummaryPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        let builder = BizumSendMoneySummaryContentBuilder(operativeData: operativeData,
                                                          dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addMultimediaContent()
        builder.addOriginAccount()
        builder.addTransferType()
        builder.addDestinationBizumContacts()
        builder.addShare(withAction: share)
        builder.addSendMoneyAgain(withAction: goToBizumHome)
        builder.addGoToGlobalPosition(withAction: goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: goToOpinator)
        }
        let viewModel = builder.build()
        self.view?.setupStandardHeader(with: viewModel.header)
        self.bizumView?.setupBizumBody(viewModel.bodyItems,
                                  actions: viewModel.bodyActionItems,
                                  showLastSeparator: true,
                                  shareViewModel: self.shareSummaryViewModel,
                                  whatsAppAction: {
                                    self.shareByWhatsApp()
                                  })
        self.view?.setupStandardFooterWithTitle(localized("footerSummary_label_andNow"), items: viewModel.footerItems)
        self.view?.build()
        self.getIsWhatsAppSharingEnabled { [weak self] enabled in
            guard !enabled else { return }
            self?.bizumView?.hideShareByWhatsappView()
        }
    }
}

private extension BizumSendMoneySummaryPresenter {
    func share() {
        trackShareByImage()
        shareCapableOperative?.getShareView(completion: { [weak self] result in
            switch result {
            case .success(let shareView, let view):
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
    
    func shareByWhatsApp() {
        trackShareByImage()
        shareCapableOperative?.getShareView(completion: { [weak self] result in
            switch result {
            case .success(let shareView, let view):
                guard
                    let self = self,
                    let shareView = shareView,
                    let containerView = view
                else { return }
                self.container?.coordinator.share(self, type: .imageWhatsapp(shareView, containerView))
            case .failure:
                return
            }
        })
    }
    
    func goToBizumHome() {
        self.container?.save(BizumFinishingOption.home)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToGlobalPosition() {
        self.container?.save(BizumFinishingOption.globalPosition)
        self.container?.stepFinished(presenter: self)
    }
    
    func goToOpinator() {
        guard let opinatorCapable = self.container?.operative as? OperativeOpinatorCapable & Operative else { return }
        opinatorCapable.showOpinator()
    }
    
    func trackShareByImage() {
        guard let type = operativeData.simpleMultipleType else {
            return
        }
        let typeParameter: String
        switch type {
        case .simple:
            typeParameter = BizumSimpleMultipleType.simple.rawValue
        case .multiple:
            typeParameter = BizumSimpleMultipleType.multiple.rawValue
        }
        trackEvent(.share, parameters: [TrackerDimension.simpleMultipleType: typeParameter])
    }
    
    func getIsWhatsAppSharingEnabled(completion: @escaping (Bool) -> Void) {
        let useCase = self.dependenciesResolver.resolve(for: GetIsWhatsAppSharingEnabledUseCase.self)
        Scenario(useCase: useCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { response in
                completion(response.isWhatsappSharingEnabled)
            }.onError { _ in
                completion(false)
            }
    }
}

extension BizumSendMoneySummaryPresenter: Shareable {
    
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [:])
        let builder = BizumSendMoneySummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        return builder.build().bodyItems.map { viewModel in
            var subtitle = ""
            if case let .standard(data) = viewModel.metadata {
                subtitle = data.subTitle.string
            }
            return viewModel.title + " " + subtitle
        }.joined(separator: "\n")
    }
}

extension BizumSendMoneySummaryPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: BizumSendMoneySummaryPage {
        BizumSendMoneySummaryPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
