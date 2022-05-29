//
//  SearchEmittersPresenterPresenter.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/14/20.
//

import Foundation
import Operative
import CoreFoundationLib
import UI

protocol SearchEmittersPresenterProtocol: OperativeStepPresenterProtocol, MenuTextWrapperProtocol {
    var view: SearchEmittersViewProtocol? { get set }
    func viewDidLoad()
    func searchBy(emitterCode: String)
    func didSelectEmitter(_ viewModel: EmitterViewModel)
    func didSelectEditAccount()
    func didSelectIncomeViewModel(_ viewModel: IncomeViewModel, emitterViewModel: EmitterViewModel)
    func loadMoreEmitters()
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class SearchEmittersPresenter {
    weak var view: SearchEmittersViewProtocol?
    var number: Int = 0
    let emitterRequest = EmitterRequest()
    var emitterList = EmitterList()
    let generator: EmitterViewModelGenerator
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    let dependenciesResolver: DependenciesResolver
    var container: OperativeContainerProtocol?
    lazy var operartiveData: BillEmittersPaymentOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    var searchEmitterUseCase: SearchEmitterUseCase {
        self.dependenciesResolver.resolve(for: SearchEmitterUseCase.self)
    }
    
    var frequentEmittersUseCase: GetFrequentEmittersUseCase {
        self.dependenciesResolver.resolve(for: GetFrequentEmittersUseCase.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var getEmitterIncomesUseCase: GetEmitterIncomesUseCase {
        return self.dependenciesResolver.resolve(for: GetEmitterIncomesUseCase.self)
    }
    
    var getBillEmittersPaymentFieldsUseCase: GetBillEmittersPaymentFieldsUseCase {
        self.dependenciesResolver.resolve(for: GetBillEmittersPaymentFieldsUseCase.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.generator = EmitterViewModelGenerator(dependenciesResolver: dependenciesResolver)
    }
}

extension SearchEmittersPresenter: SearchEmittersPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.setAccountDetail()
        self.view?.showSearchingView()
        self.getForFrequentEmitters()
    }
    
    func searchBy(emitterCode: String) {
        guard self.emitterRequest.isNotWaitingForResponse() else { return }
        self.prepareSearch()
        self.emitterRequest.setCode(emitterCode)
        let emitterCodValidator = EmittersCodeValidator()
        let sanitizeCode = emitterCodValidator.fillWithLeadingZeros(emitterCode)
        self.doSearchByCriterias(emitterCode: sanitizeCode)
    }
    
    func prepareSearch() {
        self.emitterList = EmitterList()
        self.view?.showSearchingView()
    }
    
    func loadMoreEmitters() {
        guard self.emitterRequest.isNotWaitingForResponse() else { return }
        guard self.emitterRequest.allowMoreRequests() else { return }
        self.view?.showPageLoading()
        self.doSearch(emitterCode: emitterRequest.getCode())
    }
    
    func didSelectEmitter(_ viewModel: EmitterViewModel) {
        guard viewModel.incomes.isEmpty else { return }
        self.fetchEmitterIncomes(viewModel.emitter)
    }
    
    func didFinishEmitters(emitters: [EmitterEntity]) {
        self.emitterList.append(content: emitters)
        let viewModels = self.generator.emitterViewModels(emitterList.emitters)
        if viewModels.isEmpty {
            self.view?.hidePageLoading()
            self.view?.showEmittersEmpty()
        } else {
            self.view?.hidePageLoading()
            self.view?.showEmitters(viewModels)
        }
    }
    
    func didFinishEmitterIncomes(_ emitter: EmitterEntity, incomes: [IncomeEntity]) {
        self.emitterList.update(element: emitter, incomes: incomes)
        let viewModel = generator.emitterViewModel(for: emitter, incomes)
        self.view?.updateEmitter(viewModel: viewModel)
    }
    
    func setAccountDetail() {
        guard let account = operartiveData.selectedAccount else { return }
        self.view?.showAccountDetail(
            name: account.alias ?? "",
            amaunt: account.availableAmount?.getStringValue() ?? ""
        )
    }
     
     func didSelectIncomeViewModel(_ viewModel: IncomeViewModel, emitterViewModel: EmitterViewModel) {
        self.fetchFields(forEmitter: emitterViewModel.emitter, income: viewModel.income)
    }
    
    func didSelectEditAccount() {
        self.container?.back(
            to: BillEmittersPaymentAccountSelectorPresenter.self,
            creatingAt: 0,
            step: BillEmittersPaymentAccountSelectorStep(dependenciesResolver: dependenciesResolver)
        )
    }
    
    func didTapFaqs() {
        trackEvent(.faq, parameters: [:])
        let faqModel = operartiveData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        trackerManager.trackScreen(screenId: BillEmittersPaymentFaqPage().page, extraParameters: [:])
        self.view?.showFaqs(faqModel)
    }
    
    func didTapClose() {
        container?.close()
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("billsFaqsAnalytics"), object: nil, userInfo: ["parameters": dic])
    }
}

extension SearchEmittersPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SearchEmittersPage {
        return SearchEmittersPage()
    }
}
