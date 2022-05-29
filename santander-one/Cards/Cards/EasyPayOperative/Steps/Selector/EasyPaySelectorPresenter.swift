//
//  EasyPaySelectorPresenter.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

import Operative
import CoreFoundationLib

protocol EasyPaySelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: EasyPaySelectorViewProtocol? { get set }
    
    func viewDidLoad()
    func selected(index: IndexPath)
    func close()
    func isListEmpty() -> Bool
}

extension EasyPaySelectorPresenterProtocol {
    var shouldShowProgressBar: Bool {
        return !self.isListEmpty()
    }
}

final class EasyPaySelectorPresenter {
    weak var view: EasyPaySelectorViewProtocol?
    var number = 0
    var isBackButtonEnabled = true
    var isCancelButtonEnabled = true
    var container: OperativeContainerProtocol?
    private lazy var operativeData: EasyPayOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    struct EasyPaySelectorEntity {
        let date: Date?
        var items: [CardTransactionWithCardEntity] = []
    }
    private var items: [EasyPaySelectorEntity] = []
    
    private let dependenciesResolver: DependenciesResolver
    
    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension EasyPaySelectorPresenter: EasyPaySelectorPresenterProtocol {
    func viewDidLoad() {
        items = constructDataArray()
        if !items.isEmpty {
            showItems()
            trackerManager.trackScreen(screenId: EasyPayMovementsSelectorPage().page, extraParameters: [:])
        } else {
            showEmpty()
            trackerManager.trackScreen(screenId: EasyPayEmptySelectorPage().page, extraParameters: [:])
        }
    }
    
    func selected(index: IndexPath) {
        guard index.section < items.count else { return }
        let item = items[index.section]
        let row = index.row - 1
        guard row >= 0, row < item.items.count else { return }
        let transactionWithCard = item.items[row]
        self.operativeData.productSelected = transactionWithCard
        self.container?.save(self.operativeData)
        self.view?.showLoading()
        (self.container?.operative as? OperativeSetupCapable)?.performSetup(success: { [weak self] in
            guard let self = self else { return }
            self.view?.dismissLoading(completion: {
                self.container?.stepFinished(presenter: self)
            })
        }, failed: { [weak self] (error) in
            self?.view?.dismissLoading(completion: {
                let acceptComponents = DialogButtonComponents(titled: localized("genericAlert_buttom_settings"), does: nil)
                self?.view?.showOldDialog(title: LocalizedStylableText(text: error.title ?? "", styles: nil),
                                          description: LocalizedStylableText(text: error.message ?? "", styles: nil),
                                          acceptAction: acceptComponents,
                                          cancelAction: nil,
                                          isCloseOptionAvailable: true)
            })
        })
    }
    
    func close() {
        container?.close()
    }
    
    func isListEmpty() -> Bool {
        guard let list = operativeData.list else { return true }
        return list.count == 0
    }
}

private extension EasyPaySelectorPresenter {
    func constructDataArray() -> [EasyPaySelectorEntity] {
        guard let list = operativeData.list else { return [] }
        var itemsNoDates: [CardTransactionWithCardEntity] = []
        var itemsDates: [Date: [CardTransactionWithCardEntity]] = [:]
        for element in list {
            if let date = element.cardTransactionEntity.operationDate {
                var items: [CardTransactionWithCardEntity]
                if let oldItems = itemsDates[date] {
                    items = oldItems
                } else {
                    items = []
                }
                items.append(element)
                itemsDates[date] = items
            } else {
                itemsNoDates.append(element)
            }
        }
        var elements: [EasyPaySelectorEntity] = []
        for date in itemsDates.keys.sorted(by: > ) {
            if let items = itemsDates[date] {
                let sortedItems = items.sorted { return ($0.cardEntity.alias ?? "") > ($1.cardEntity.alias ?? "") }
                let element = EasyPaySelectorEntity(date: date, items: sortedItems)
                elements.append(element)
            }
        }
        if !itemsNoDates.isEmpty {
            let sortedItems = itemsNoDates.sorted { return ($0.cardEntity.alias ?? "") > ($1.cardEntity.alias ?? "") }
            let element = EasyPaySelectorEntity(date: nil, items: sortedItems)
            elements.append(element)
        }
        return elements
    }
    
    private func showEmpty() {
        view?.hideTopTexts()
        let section = EasyPayTableModelViewSection()
        let emptyView = EmptyViewModelView(title: localized("empty_postponeBuy_title_notRecentPurchases"),
                                           text: localized("empty_postponeBuy_label_notRecentPurchases"))
        section.add(item: emptyView)
        view?.setSections([section])
    }
    
    private func showItems() {
        view?.setTitle(localized("deeplink_postponeBuy_label_payInInstallments"),
                       subtitle: localized("deeplink_postponeBuy_label_notFindaAccount"))
        let sections = items.reduce([EasyPayTableModelViewSection]()) { (res, item) in
            let section = EasyPayTableModelViewSection()
            let header = EasyPayTitleTableModelView(date: timeManager.toString(date: item.date,
                                                                               outputFormat: .d_MMM_yyyy)?.uppercased())
            section.add(item: header)
            let transactions = item.items.map { (transactionWithCard)  in
                return EasyPayCardModelView(card: transactionWithCard.cardEntity,
                                            transaction: transactionWithCard.cardTransactionEntity)
            }
            section.add(items: transactions)
            let footer = EasyPaySeparatorModelView(heightSepartor: 8,
                                                   color: .paleGrey)
            section.add(item: footer)
            return res + [section]
        }
        view?.setSections(sections)
    }
}
