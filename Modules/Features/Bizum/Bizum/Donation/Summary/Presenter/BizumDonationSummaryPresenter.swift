//
//  BizumDonationSummaryPresenter.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 11/02/2021.
//

import CoreFoundationLib
import Operative

final class BizumDonationSummaryPresenter {
    weak var summaryView: BizumSummaryViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    lazy var operativeData: BizumDonationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private var shareCapableOperative: ShareOperativeCapable? {
        self.container?.operative as? ShareOperativeCapable
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumDonationSummaryPresenter: BizumSendMoneySummaryPresenterProtocol {
    var view: OperativeSummaryViewProtocol? {
        get {
            return self.summaryView
        }
        set {
            self.summaryView = newValue as? BizumSummaryViewProtocol
        }
    }
    
    func viewDidLoad() {
        let builder = BizumDonationSummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addMultimediaContent()
        builder.addTransferType()
        builder.addOriginAccount()
        builder.addDestination()
        builder.addShare(withAction: share)
        builder.addGoToBizumHome(withAction: self.goToBizumHome)
        builder.addGoToGlobalPosition(withAction: self.goToGlobalPosition)
        if self.container?.operative is OperativeOpinatorCapable {
            builder.addGoToOpinator(withAction: self.goToOpinator)
        }
        let viewModel = builder.build()
        self.summaryView?.setupStandardHeader(with: viewModel.header)
        self.summaryView?.setupBizumBody(viewModel.bodyItems,
                                         actions: viewModel.bodyActionItems,
                                         showLastSeparator: false,
                                         shareViewModel: nil,
                                         whatsAppAction: nil)
        self.view?.setupStandardFooterWithTitle(localized("summary_label_nowThat"), items: viewModel.footerItems)
        self.view?.build()
    }
}

private extension BizumDonationSummaryPresenter {
    
    func share() {
        trackShareByImage()
        shareCapableOperative?.getShareView { [weak self] result in
            switch result {
            case .success(let shareView, let view):
                guard let self = self,
                    let shareView = shareView,
                    let containerView = view
                else { return }
                self.container?.coordinator.share(self, type: .image(shareView, containerView))
            case .failure:
                break
            }
        }
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
        self.trackEvent(.share, parameters: [TrackerDimension.simpleMultipleType: BizumSimpleMultipleType.simple.rawValue])
    }
}

extension BizumDonationSummaryPresenter: Shareable {
    func getShareableInfo() -> String {
        trackEvent(.share, parameters: [.simpleMultipleType: BizumSimpleMultipleType.simple.rawValue])
        let builder = BizumDonationSummaryContentBuilder(operativeData: operativeData, dependenciesResolver: self.dependenciesResolver)
        return builder.build().bodyItems.map { viewModel in
            var subtitle = ""
            if case let .standard(data) = viewModel.metadata {
                subtitle = data.subTitle.string
            }
            return viewModel.title + " " + subtitle
        }.joined(separator: "\n")
    }
}

extension BizumDonationSummaryPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumDonationSummaryPage {
        return BizumDonationSummaryPage()
    }

    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: BizumSimpleMultipleType.simple.rawValue
        ]
    }
}
