protocol WithdrawMoneyHistoricalNavigatorProtocol: OperativesNavigatorProtocol {
    func goToDetail(of dispensation: Dispensation, card: Card, detail: CardDetail, account: Account?, delegate: HistoricalDispensationDetailPresenterDelegate)
    func showListDialog(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType)
}

class WithdrawMoneyHistoricalNavigator {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init (presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
}

extension WithdrawMoneyHistoricalNavigator: WithdrawMoneyHistoricalNavigatorProtocol {
    func goToDetail(of dispensation: Dispensation, card: Card, detail: CardDetail, account: Account?, delegate: HistoricalDispensationDetailPresenterDelegate) {
        let navigationController = drawer.currentRootViewController as? NavigationController
        let presenter = presenterProvider.cardOperatives.historicalDispensationDetailPresenter
        presenter.dispensation = dispensation
        presenter.card = card
        presenter.cardDetail = detail
        presenter.account = account
        presenter.delegate = delegate
        navigationController?.pushViewController(presenter.view, animated: true)
    }
    
    func showListDialog(title: LocalizedStylableText, items: [ListDialogItem], type: ListDialogType) {
        let dialogPresenter = presenterProvider.listDialogPresenter(title: title, items: items, type: type)
        dialogPresenter.view.modalPresentationStyle = .overCurrentContext
        dialogPresenter.view.modalTransitionStyle = .crossDissolve
        drawer.present(dialogPresenter.view, animated: true)
    }
}
