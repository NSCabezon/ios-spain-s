import Foundation

class ProductHomeTransactionsPresenter: PrivatePresenter<ProductHomeTransactionsViewController, ProductHomeNavigatorProtocol, ProductHomeTransactionsPresenterProtocol>, ProductProfileSeteable {
    
    var options = [ProductOption]()
    private var isWaitingResponse = false
    private var isShowingLoading: Bool = false
    
    var productProfile: ProductProfile?
    private var sections = [TableModelViewSection]()
    var transactions = [GenericTransactionProtocol]()
    private var placeholders: [Placeholder]?
    private var topInset: Double?
    private var showLoadingCancelableWorkTask: DispatchWorkItem?
    private var showOptionsCancelableWorkTask: DispatchWorkItem?
    private var filterView: TransactionFilterModelView?
    private var headerSection = ProductOptionSection()
    private var searchProfile: SearchParameterCapable? {
        return productProfile?.searchProfile
    }
    
    private var transactionTitle: LocalizedStylableText? {
        return searchProfile?.filterDescription ?? productProfile?.transactionHeaderTitle
    }
    
    deinit {
        cancelShowOptions()
    }
    
    func reloadContent(request: Bool) {
        UseCaseWrapper(with: useCaseProvider.getProductConfigUseCase(),
                       useCaseHandler: self.useCaseHandler,
                       errorHandler: self.genericErrorHandler,
                       queuePriority: .veryHigh,
                       onSuccess: { [weak self] (productConfigResponse) in
            
            self?.productProfile?.completionOptions = { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.headerSection.clean()
                if !result.isEmpty {
                    guard let productProfile = strongSelf.productProfile else {
                        return
                    }
                    let cellOptions = ProductOptionsViewModel(dependencies: strongSelf.dependencies, backgroundColor: productProfile.optionsBackgroundColor)
                    
                    if let profile = strongSelf.productProfile as? CoachmarkProfile {
                        cellOptions.firstSeparatorCoachmarkId = profile.coachmarkToInsertInFirstSeparator
                        cellOptions.secondSeparatorCoachmarkId = profile.coachmarkToInsertInSecondSeparator
                    }
                    cellOptions.delegate = strongSelf
                    strongSelf.options = result
                    cellOptions.activeOptions = strongSelf.options.count <= 3 ? strongSelf.options : strongSelf.handlerOptions(WithArray: strongSelf.options)
                    strongSelf.headerSection.add(item: cellOptions)
                }
                strongSelf.productProfile?.addExtraHeaderSection(section: strongSelf.headerSection)
                if strongSelf.productProfile?.isHeaderCellHidden == false {
                    let filterCell = TransactionFilterModelView(strongSelf.transactionTitle, strongSelf.dependencies, strongSelf, strongSelf.productProfile?.isFilterIconVisible ?? false)
                    filterCell.showPdfAction = strongSelf.productProfile?.showPdfAction
                    filterCell.isClearAvailable = strongSelf.searchProfile?.isFiltered ?? false
                    filterCell.filterButtonCoachmarkId = (strongSelf.productProfile is CoachmarkProfile) ? (strongSelf.productProfile as! CoachmarkProfile).coachmarkToInsertInSearchButton : nil
                    filterCell.didSelectClearFilter = { [weak self] in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.clearFilter()
                    }
                    
                    strongSelf.headerSection.add(item: filterCell)
                    strongSelf.filterView = filterCell
                } else {
                    strongSelf.filterView = nil
                }
                strongSelf.cancelShowOptions()
                
                let task = DispatchWorkItem(qos: DispatchQoS.userInteractive, flags: [DispatchWorkItemFlags.assignCurrentContext, DispatchWorkItemFlags.enforceQoS], block: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.view.replaceHeaderSection(with: strongSelf.headerSection)
                })
                strongSelf.showOptionsCancelableWorkTask = task
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: task)
                if request {
                    strongSelf.requestTransactions()
                }
            }
            self?.productProfile?.productConfig = productConfigResponse.productConfig
        })
    }
    
    private func cancelShowOptions() {
        if let task = showOptionsCancelableWorkTask {
            task.cancel()
            showOptionsCancelableWorkTask = nil
        }
    }
    
    func clearFilter() {
        searchProfile?.clear()
        filterDidChange()
    }
    
    //=================================
    // MARK: - Handle options
    //=================================
    
    private func handlerOptions(WithArray arrayOptions: [ProductOption]) -> [ProductOption] {
        
        var reduxOptions: [ProductOption]
        
        if view.isIphone4or5 {
            reduxOptions = Array(arrayOptions[0 ..< 2])
            reduxOptions.append((localized(key: "productOption_button_more"), "icnMore", 2))
            return reduxOptions
        } else {
            if arrayOptions.count > 4 {
                reduxOptions = Array(arrayOptions[0 ..< 3])
                reduxOptions.append((localized(key: "productOption_button_more"), "icnMore", 3))
                return reduxOptions
            } else {
                return arrayOptions
            }
        }
    }
    
    func didChange(toProductIndex index: Int) {
        productProfile?.selectProduct(at: index)
        productProfile?.loadProductConfig { [weak self] in
            self?.requestTransactions()
        }
    }
    
    private func cancelShowLoading() {
        if let task = showLoadingCancelableWorkTask {
            task.cancel()
            showLoadingCancelableWorkTask = nil
        }
    }
    
    func requestTransactions(removeCurrentData: Bool = true, requestFromBeginning: Bool = false) {
        guard productProfile?.productConfig != nil else {
            return
        }
        cancelShowLoading()
        if removeCurrentData {
            sections = [headerSection]
            let task = DispatchWorkItem(qos: DispatchQoS.userInteractive, flags: [DispatchWorkItemFlags.assignCurrentContext, DispatchWorkItemFlags.enforceQoS], block: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.replaceAllSections(with: [strongSelf.headerSection])
                strongSelf.startMainLoadingAnimation()
            })
            showLoadingCancelableWorkTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: task)
        }
        isWaitingResponse = true
        filterView?.showPdfAction = nil
        
        let completion: ([DateProvider]) -> Void = { [weak self] (response) in
            defer {
                self?.isWaitingResponse = false
            }
            guard let strongSelf = self, strongSelf.view.isViewLoaded else {
                return
            }
            strongSelf.cancelShowOptions()
            strongSelf.cancelShowLoading()
            if strongSelf.sections.isEmpty {
                strongSelf.sections.append(strongSelf.headerSection)
            } else {
                strongSelf.sections[0] = strongSelf.headerSection
            }
            if let lastSection = strongSelf.sections.last, lastSection is LoadingSection {
                strongSelf.sections.removeLast()
            }
            if strongSelf.sections.last?.items.first is TransactionMoreModelView || strongSelf.sections.last?.items.first is  TransactionMoreEmptyModelView {
                strongSelf.sections.removeLast()
            }
            if let empty: TransactionMoreEmptyModelView = strongSelf.sections.last?.items.first as? TransactionMoreEmptyModelView {
                empty.assignedHeight = strongSelf.view.avaliableSpace - 54 
            }
            strongSelf.loadSections(data: response)
            
            if strongSelf.productProfile?.isMorePages == true && response.count > 0 {
                let section = LoadingSection()
                let loading = SecondaryLoadingModelView(dependencies: strongSelf.dependencies)
                section.add(item: loading)
                strongSelf.sections.append(section)
            }
            let hasEmptyView = strongSelf.sections.contains(where: {$0.isKind(of: EmptyViewSection.self)})
            if !strongSelf.sections.contains(where: {$0.isKind(of: TransactionDaySection.self)}) && !hasEmptyView {
                let emptySection = EmptyViewSection()
                emptySection.add(item: EmptyViewModelView(strongSelf.stringLoader.getString("generic_label_emptyList"), identifier: "withdrawHistorical_empty", strongSelf.dependencies))
                strongSelf.sections.append(emptySection)
            }
            
            if removeCurrentData && strongSelf.isShowingLoading {
                strongSelf.endMainLoadingAnimation {
                    strongSelf.replaceAllSections(with: strongSelf.sections)
                    if strongSelf.sections.contains(where: {$0.isKind(of: TransactionDaySection.self)}) {
                        strongSelf.productProfile?.startSecondaryRequest()
                    }
                }
            } else {
                strongSelf.replaceAllSections(with: strongSelf.sections, shouldScrollToTop: false)
                if strongSelf.sections.contains(where: {$0.isKind(of: TransactionDaySection.self)}) {
                    strongSelf.productProfile?.startSecondaryRequest()
                }
            }
            
            strongSelf.filterView?.showPdfAction = strongSelf.productProfile?.showPdfAction
            
            if removeCurrentData {
                strongSelf.view.scrollToTop()
            }
        }
        
        productProfile?.requestTransactions(fromBeginning: requestFromBeginning, completion: completion)
    }
    
    func addReceivedData(_ data: [DateProvider]) {
        if sections.count > 0 {
            sections.removeLast()
        }
        loadSections(data: data)
        replaceAllSections(with: sections)
    }
    
    private func replaceAllSections(with sections: [TableModelViewSection], shouldScrollToTop scrollToTop: Bool = true) {
        view.replaceAllSections(with: sections, shouldScrollToTop: scrollToTop) {}
    }
    
    private func removeLoading(sections: [TableModelViewSection]) -> [TableModelViewSection] {
        var result = sections
        if sections.last is LoadingSection {
            result.removeLast()
        }
        return result
    }
    
    private func loadSections(data: [DateProvider]) {
        for item in data {
            let lastSectionDate = (sections.last as? TransactionDaySection)?.date
            if let lastSectionDate = lastSectionDate,
                let itemDate = item.transactionDate, Calendar.current.isDate(itemDate, inSameDayAs: lastSectionDate) {
                item.shouldDisplayDate = false
                sections.last?.items.append(item)
            } else {
                let section = TransactionDaySection(date: item.transactionDate)
                section.items.append(item)
                item.shouldDisplayDate = true
                sections.append(section)
            }
        }
    }
    
    func startMainLoadingAnimation() {
        isShowingLoading = true
        if let loadingPlaceholder = productProfile?.loadingPlaceholder {
            placeholders = [loadingPlaceholder]
        } else {
            placeholders = nil
        }
        topInset = productProfile?.loadingTopInset
        view.showLoading()
        view.isScrollEnabled = false
        view.fixBounds()
    }
    
    func endMainLoadingAnimation(completion: @escaping () -> Void) {
        isShowingLoading = false
        hideLoading(completion: completion)
        view.isScrollEnabled = true
        view.hideLoading()
    }
    
    func updateIndex (index: Int) {
        view.updateIndex(index: index)
    }
    
    func updateAllIndex() {
        view.tableView.reloadData()
    }
    
    fileprivate func showCoachmarks() {
        if let productHomePresenter = productProfile?.delegate as? ProductHomeCoachmarkPresenter, !productHomePresenter.coachmarksInfo.areAllCoachmarksLoaded {
            view.findCoachmarks(neededIds: (productProfile as? CoachmarkProfile)?.transactionIdentifiers ?? []) { [weak self] coachmarks in
                let identifiers = (self?.productProfile as? CoachmarkProfile)?.transactionIdentifiers
                if identifiers?.count == coachmarks.filter({ $0.value != .zero }).count {
                    productHomePresenter.transactionCoachmarksDidFinishLoad()
                }
            }
        }
    }
}

extension ProductHomeTransactionsPresenter: Presenter {}

extension ProductHomeTransactionsPresenter: ProductHomeTransactionsPresenterProtocol {
    var numberOfDefaultSections: Int {
        return productProfile?.numberOfDefaultSections ?? 0
    }
    
    var transactionsBackgroundColor: TransactionsBackgroundColor {
        get {
            return .white
        } set {
            view.setTransactionsBackground(color: newValue)
        }
    }
    
    var hasDefaultRows: Bool {
        return productProfile?.hasDefaultRows ?? true
    }
    
    func willDisplayLastCell() {
        if productProfile?.isMorePages == true && isWaitingResponse == false && sections.last is LoadingSection {
            requestTransactions(removeCurrentData: false)
        }
    }
    
    func didSelectTransaction(section: Int, position: Int) {
        guard let transactionPosition = effectivePositionForElementInSection(sectionNumber: section, positionNumber: position) else {
            return
        }
        productProfile?.transactionDidSelected(at: transactionPosition)
    }
    
    private func effectivePositionForElementInSection(sectionNumber: Int, positionNumber: Int) -> Int? {
        guard sections.count > sectionNumber else {
            return nil
        }
        let section = sections[sectionNumber]
        let transactionDaySections = sections.filter { (section) -> Bool in
            section.isKind(of: TransactionDaySection.self)
        }
        var transactionPosition = 0
        if let sectionIndex = transactionDaySections.firstIndex(of: section) {
            for transactionDaySection in transactionDaySections {
                if let index = transactionDaySections.firstIndex(of: transactionDaySection) {
                    if index < sectionIndex {
                        transactionPosition += transactionDaySection.items.count
                    }
                }
            }
        }
        transactionPosition += positionNumber
        return transactionPosition
    }
    
    func willDisplayElement(section: Int, position: Int) {
        guard let elementPosition = effectivePositionForElementInSection(sectionNumber: section, positionNumber: position) else {
            return
        }
        productProfile?.displayIndex(index: elementPosition)
    }
    
    func didEndDisplayingElement(section: Int, position: Int) {
        guard let elementPosition = effectivePositionForElementInSection(sectionNumber: section, positionNumber: position) else {
            return
        }
        productProfile?.endDisplayIndex(index: elementPosition)
    }
    
    func showPresenterLoading(type: LoadingViewType) {
        let text = LoadingText(title: localized(key: "generic_popup_loadingContent"),
                               subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               placeholders: placeholders,
                               topInset: topInset ?? 14,
                               loadingImageType: .points)
        showLoading(info: info)
    }
    
    func hidePresenterLoading() {
        hideLoading()
    }
}

extension ProductHomeTransactionsPresenter: FilterManager {
    func filter() {
        if let parameterSetup = productProfile?.searchProfile {
            navigator.goToTransactionSearch(parameterSetup: parameterSetup, filterChangeDelegate: self)
        }
    }
}

//=================================
// MARK: - Options Cell Delegate
//=================================
extension ProductHomeTransactionsPresenter: ProductOptionViewModelDelegate {
    
    func productOption(didSelectIndex index: Int) {
        if view.isIphone4or5 {
            if options.count > 3 && index == 2 {
                goToProductHomeDialog(fromIndex: 2)
            } else {
                productProfile?.optionDidSelected(at: options[index].index)
            }
        } else {
            if options.count >= 5 && index == 3 {
                goToProductHomeDialog(fromIndex: 3)
            } else {
                productProfile?.optionDidSelected(at: options[index].index)
            }
        }
    }
    
    private func goToProductHomeDialog(fromIndex index: Int) {
        navigator.goToProductHomeDialog(withOptions: Array(options[index ..< options.count]), delegate: self)
    }
}

extension ProductHomeTransactionsPresenter: ProductHomeViewDelegate {
    func didSelectOption(at index: Int) {
        productProfile?.optionDidSelected(at: index)
    }
}

extension ProductHomeTransactionsPresenter: FilterChangeDelegate {
    func filterDidChange() {
        requestTransactions(removeCurrentData: true, requestFromBeginning: true)
        filterView?.update(with: transactionTitle)
        filterView?.isClearAvailable = searchProfile?.isFiltered ?? false
    }
}
