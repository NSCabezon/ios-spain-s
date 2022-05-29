//
//  SendMoneyAccountSelectorPresenter.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Operative
import CoreFoundationLib
import CoreDomain

protocol SendMoneyAccountSelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: SendMoneyAccountSelectorView? { get set }
    func viewDidLoad()
    func didSelectAccount(_ cardViewModel: OneAccountSelectionCardItem)
    func didSelectSeeHiddentAccounts()
    func viewWillAppear()
    func back()
    func close()
}

final class SendMoneyAccountSelectorPresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyAccountSelectorView?
    let dependenciesResolver: DependenciesResolver
    var shouldShowProgressBar: Bool = false
    
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SendMoneyAccountSelectorPresenter: SendMoneyAccountSelectorPresenterProtocol {
    func viewDidLoad() {
        if operativeData.accountVisibles.count == 0,
           operativeData.accountNotVisibles.count > 0 {
            self.view?.showHiddenAccountsWarning()
        }
        self.trackScreen()
    }
    
    func viewWillAppear() {
        let accountVisibles = operativeData.accountVisibles.map { self.mapToOneAccountSelectionCardViewModel(from: $0, status: .inactive) }
        let accountNotVisibles = operativeData.accountNotVisibles.map { self.mapToOneAccountSelectionCardViewModel(from: $0, status: .inactive) }
        self.view?.setSections(
            to: SendMoneyAccountSelectorSectionBuilder(
                accountVisibles: accountVisibles,
                accountNotVisibles: accountNotVisibles
            )
            .buildSections()
        )
    }
    
    func didSelectAccount(_ cardViewModel: OneAccountSelectionCardItem) {
        self.operativeData.selectedAccount = cardViewModel.account
        self.container?.stepFinished(presenter: self)
    }
    
    func didSelectSeeHiddentAccounts() {
        self.trackerManager.trackEvent(screenId: self.trackerPage.page, eventId: SendMoneySourceAccountPage.Action.viewHiddenAccounts.rawValue, extraParameters: [:])
    }
    
    func close() {
        self.container?.close()
    }
    
    func back() {
        self.container?.back()
    }
}

private extension SendMoneyAccountSelectorPresenter {
    func mapToOneAccountSelectionCardViewModel(from: AccountRepresentable, status: OneAccountSelectionCardItem.CardStatus) -> OneAccountSelectionCardItem {
        var checkSelectedStatus = status
        if let selectedAccount = operativeData.selectedAccount,
           selectedAccount.equalsTo(other: from) {
            checkSelectedStatus = .selected
        }
        let type = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.amountToShow ?? SendMoneyAmountToShow.currentBalance
        let numberFormatter = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self)
        return OneAccountSelectionCardItem(account: from,
                                           cardStatus: checkSelectedStatus,
                                           accessibilityOfView: "",
                                           amountToShow: type,
                                           numberFormater: numberFormatter)
    }
}

extension SendMoneyAccountSelectorPresenter: AutomaticScreenActionTrackable {

    var trackerPage: SendMoneySourceAccountPage {
        SendMoneySourceAccountPage()
    }

    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
