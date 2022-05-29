import Foundation

protocol BillAndTaxesFilterNavigatorProtocol: MenuNavigator {
    func goBack()
    func navigateToAccounts(_ accounts: [Account], delegate: AccountSelectionDelegate?)
}

protocol BillAndTaxesFilterDelegate: AnyObject {
    func updateFilter(with filterParameters: BillAndTaxesFilterParameters)
}

class BillAndTaxesFilterPresenter: PrivatePresenter<FormViewController, BillAndTaxesFilterNavigatorProtocol, FormPresenterProtocol> {
    private let conceptMaxLength = DomainConstant.maxLengthTransferConcept
    weak var filterDelegate: BillAndTaxesFilterDelegate?
    var filter: BillAndTaxesFilterParameters!
    private var visibleAccounts = [Account]()
    private var accountSelector: SelectorStackModel?
    
    var accountTitle: LocalizedStylableText {
        return stringLoader.getString("search_select_account")
    }
    
    var viewTitle: LocalizedStylableText {
        return stringLoader.getString("toolbar_title_searchReceipts")
    }
    
    var buttonTitle: LocalizedStylableText {
        return stringLoader.getString("search_button_search")
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.continueButton.set(localizedStylableText: buttonTitle, state: .normal)
        view.styledTitle = viewTitle
        view.isSideMenuCapable = true
        view.showMenuClosure = { [weak self] in
            self?.toggleSideMenu()
        }
        startLoading()

        visibleAccounts { [weak self] in
            self?.updateFilterAccount()
            self?.endLoading { [weak self] in
                self?.makeSections()
            }
        }
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.BillAndTaxesSearch().page
    }
    
    // MARK: - Helpers
    
    private func makeSections() {
        var sections: [StackSection] = []
        sections.append(makeAccountSection(with: filter))
        sections.append(makeTimeFrameSection(with: filter))
        sections.append(makeStateSection(with: filter))
        view.dataSource.reloadSections(sections: sections)
    }
    
    private func makeAccountSection(with filter: BillAndTaxesFilterParameters) -> StackSection {
        let accountSection = StackSection()
        let titleItem = TitleLabelStackModel(title: accountTitle, insets: Insets(left: 14, right: 14, top: 14, bottom: 0))
        accountSection.add(item: titleItem)
        let accountDescription = filter.account?.getAliasAndInfo()
        let accountSelectorModel = SelectorStackModel(placeholder: stringLoader.getString("search_label_selectAccount"), title: accountDescription)
        accountSection.add(item: accountSelectorModel)
        accountSelectorModel.onSelection = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigator.navigateToAccounts(strongSelf.visibleAccounts, delegate: self)
        }
        self.accountSelector = accountSelectorModel
        return accountSection
    }
    
    private func makeTimeFrameSection(with filter: BillAndTaxesFilterParameters) -> StackSection {
        let timeFrameSection = StackSection()
        let titleItem = TitleLabelStackModel(title: stringLoader.getString("search_label_datesRange"), insets: Insets(left: 10, right: 10, top: 16, bottom: 0))
        timeFrameSection.add(item: titleItem)
        
        let rangeDate = createDateRange()
        timeFrameSection.add(item: rangeDate)
        
        let descriptionItem = TitleLabelStackModel(title: stringLoader.getString("search_text_dateRangeMaxMin"), numberOfLines: 0, titleStyle: .description, insets: Insets(left: 14, right: 14, top: 6, bottom: 0))
        timeFrameSection.add(item: descriptionItem)

        return timeFrameSection
    }
        
    private func createDateRange() -> DateRangeFieldStackModel {
        let lowerDateRange = Calendar.current.date(byAdding: .month, value: -15, to: Date())
        let rangeDate = DateRangeFieldStackModel(leftTitle: stringLoader.getString("search_label_sinceDate"), rightTitle: stringLoader.getString("search_label_until"), initialDateFrom: filter.dateRange.0, initialDateTo: filter.dateRange.1, minimumDateRange: lowerDateRange, maximumDateRange: Date(), privateComponent: dependencies, insets: Insets(left: 10, right: 10, top: 6, bottom: 2))
        rangeDate.onSelection = { [weak self] (dateFrom, dateTo) in
            self?.filter.dateRange = (dateFrom, dateTo)
        }

        return rangeDate
    }
    
    private func makeStateSection(with filter: BillAndTaxesFilterParameters) -> StackSection {
        let stateSection = StackSection()
        let titleItem = TitleLabelStackModel(title: stringLoader.getString("search_label_conditionOfReceipt"), insets: Insets(left: 14, right: 14, top: 16, bottom: 2))
        stateSection.add(item: titleItem)
        let stateSelectorModel = OptionsPickerStackModel(items: BillAndTaxesStatus.allCases, selected: filter.status, dependencies: dependencies) { [weak self] selected in
            self?.filter.status = selected
        }
        stateSection.add(item: stateSelectorModel)

        return stateSection
    }
    
    private var timeOptions: [(value: String, valueToDisplay: String)] {
        let oneMonth = stringLoader.getString("search_buttom_oneMonth").text
        let twoMonths = stringLoader.getString("search_buttom_twoMonths").text
        let sixMonths = stringLoader.getString("search_buttom_sixMonths").text
        let oneYear = stringLoader.getString("search_buttom_oneYear").text
        
        return [(value: "1", valueToDisplay: oneMonth), (value:"2", valueToDisplay: twoMonths), (value: "6", valueToDisplay: sixMonths), (value:"12", valueToDisplay: oneYear)]
    }
    
    private func updateFilterAccount() {
        guard filter.account == nil else {
            return
        }
        if visibleAccounts.count == 1 {
            filter.account = visibleAccounts.first
        }
    }
    
    private func visibleAccounts(completion: @escaping () -> Void) {
        let useCase = useCaseProvider.getPGDataUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { [weak self] (response) in
            self?.visibleAccounts = response.globalPosition.accounts.getVisibles()
            completion()
        }, onError: { (_) in
            completion()
        })
    }
    
    private func startLoading() {
        let type = LoadingViewType.onView(view: view.view, frame: nil, position: .center, controller: view)
        let text = LoadingText(title: localized(key: "generic_popup_loading"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        showLoading(info: info)
    }
    
    private func endLoading(completion: (() -> Void)?) {
        hideLoading(completion: completion)
    }
    
    private func updateAccountDescription(with account: Account?) {
        accountSelector?.title = account?.getAliasAndInfo()
    }
}

// MARK: - FormPresenterProtocol

extension BillAndTaxesFilterPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        guard filter.account != nil else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "search_alert_text_selectAccount", phone: nil, completion: nil)
            return
        }
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.search.rawValue, parameters: [:])
        if let dateFrom = filter.dateRange.0, let dateTo = filter.dateRange.1 {
            let components = Calendar.current.dateComponents([.day], from: dateFrom, to: dateTo)
            guard let days = components.day, days <= 60 else {
                showError(keyDesc: "search_text_dateRangeMaxMin")
                return
            }
        }
        
        filterDelegate?.updateFilter(with: filter)
        navigator.goBack()
    }
    
}

extension BillAndTaxesFilterPresenter: DateRangeValidatorCapable {}

// MARK: - AccountSelectionDelegate

extension BillAndTaxesFilterPresenter: AccountSelectionDelegate {
    
    func didSelect(account: Account) {
        filter.account = account
        updateAccountDescription(with: account)
    }
    
}

extension BillAndTaxesFilterPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
