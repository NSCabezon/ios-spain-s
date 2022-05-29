import Foundation
import CoreFoundationLib

class PersonalAreaFrequentOperativesPresenter: PrivatePresenter<PersonalAreaFrequentOperativesViewController, PersonalAreaNavigatorProtocol, PersonalAreaFrequentOperativesProtocol> {
    private var sections = [TableModelViewSection]()
    private var maxSelectable = 0
    private var isGlobalPositionReloading = false
    private lazy var loadOperativesSuperUseCase: LoadPersonalAreaFrequentOperativesSuperUseCase = {
        return useCaseProvider.getLoadPersonalAreaFrequentOperativesSuperUseCase(useCaseHandler: useCaseHandler)
    }()
    lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.useCaseProvider.dependenciesResolver)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
    
   override var screenId: String? {
        return TrackerPagePrivate.PersonalAreaDirectAccesConfiguration().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        let type = LoadingViewType.onView(view: view.view, frame: nil, position: .center, controller: view)
        let info = LoadingInfo(type: type, loadingText: .empty)
        showLoading(info: info)
        makeSections()
    }
    
    private func makeSections() {
        sections.append(makeHeader())
        makeOperatives { [weak self] (optionsSection) in
            guard let strongSelf = self else { return }
            strongSelf.sections.append(optionsSection)
            strongSelf.view.addSections(strongSelf.sections)
        }
    }
    
    private func makeHeader() -> TableModelViewSection {
        let headerSection = TableModelViewSection()
        let headerViewModel = GenericOperativeHeaderTitleAndDescriptionViewModel(title: stringLoader.getString("frequentOperative_title_seeOrderAccess"), description: stringLoader.getString("frequentOperative_label_seeOrderAccess"))
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTitleAndDescriptionView.self, dependencies: dependencies)
        headerSection.add(item: headerCell)
        
        return headerSection
    }
    
    private func makeOperatives(_ completion: @escaping (TableModelViewSection) -> Void ) {
        loadOperativesSuperUseCase.execute { [weak self] (options, maximumOptions) in
            self?.hideLoading()
            let operatives = options
            self?.maxSelectable = maximumOptions
            let operativesSection = TableModelViewSection()
            let title = SettingsTitleHeaderViewModel(title: .empty)
            operativesSection.setHeader(modelViewHeader: title)
            
            for operative in operatives {
                guard let strongSelf = self else {
                    completion(operativesSection)
                    return
                }
                let key = operative.directLink.descriptionKey
                let title = strongSelf.stringLoader.getString(key)
                let item = DraggableImageAndDescriptionViewModel(itemIdentifier: operative.directLink.rawValue, title: title, switchState: operative.isEnabled, imageKey: operative.directLink.iconKey, isActive: true, dependencies: strongSelf.dependencies) { [weak self] newValue in
                    
                    if newValue == true {
                        self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaDirectAccesConfiguration.Action.activateDeeplink.rawValue, parameters: [TrackerDimensions.deeplinkLogin: operative.directLink.trackerId])
                    } else {
                        self?.trackEvent(eventId: TrackerPagePrivate.PersonalAreaDirectAccesConfiguration.Action.deactivateDeeplink.rawValue, parameters: [TrackerDimensions.deeplinkLogin: operative.directLink.trackerId])
                    }
                    
                    guard let strongSelf = self, newValue == true && strongSelf.selectedOptionsCount > strongSelf.maxSelectable else { return }
                    self?.disableSwitchWithIdentifier(operative.directLink.rawValue)
                    let acceptButton = DialogButtonComponents(titled: strongSelf.stringLoader.getString("generic_button_accept")) { [weak self] in
                        self?.view.refreshData()
                    }
                    
                    Dialog.alert(title: nil, body: strongSelf.stringLoader.getString("frequentOperative_error_maxDeeplinks"),
                                 withAcceptComponent: acceptButton,
                                 withCancelComponent: nil,
                                 source: strongSelf.view)
                }
                operativesSection.add(item: item)
            }
            completion(operativesSection)
        }
    }

    private var selectedOptionsCount: Int {
        return sections.last?.items.filter {
            guard let item = $0 as? DraggableImageAndDescriptionViewModel else { return false }
            return item.switchState == true }.count ?? 0
    }
        
    private func disableSwitchWithIdentifier(_ identifier: String) {
        let option = (sections.last?.items as? [DraggableImageAndDescriptionViewModel])?.first { $0.itemIdentifier == identifier }
        option?.switchState = false
    }
}

extension PersonalAreaFrequentOperativesPresenter: SessionDataManagerProcessDelegate {}

extension PersonalAreaFrequentOperativesPresenter: PersonalAreaPGReloadableCapable {}

// MARK: - Presenter

extension PersonalAreaFrequentOperativesPresenter: Presenter {}

// MARK: - SideMenuCapable

extension PersonalAreaFrequentOperativesPresenter: SideMenuCapable {
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return !isLoading() && !isGlobalPositionReloading
    }
}

extension PersonalAreaFrequentOperativesPresenter: PersonalAreaFrequentOperativesProtocol {
    func didMoveItem(item: TableModelViewProtocol) {
        guard let item = item as?  DraggableImageAndDescriptionViewModel else { return }
        let itemIdentifier = item.itemIdentifier
        guard let directLink = DirectLinkTypeItem(rawValue: itemIdentifier) else { return }
        trackEvent(eventId: TrackerPagePrivate.PersonalAreaDirectAccesConfiguration.Action.moveDeeplink.rawValue, parameters: [TrackerDimensions.deeplinkLogin: directLink.trackerId])
    }
    
    func saveConfiguration() {
        if selectedOptionsCount  == 0 {
            displayConfirmationMessage()
        } else {
            storeChanges()
        }
    }
    
    private func displayConfirmationMessage() {
        let cancel = DialogButtonComponents(titled: stringLoader.getString("generic_button_cancel")) {}
        let acceptButton = DialogButtonComponents(titled: stringLoader.getString("generic_button_accept")) { [weak self] in
            self?.storeChanges()
        }
        
        Dialog.alert(title: nil, body: stringLoader.getString("frequentOperative_alert_activateDeeplinks"),
                     withAcceptComponent: acceptButton,
                     withCancelComponent: cancel,
                     source: view)
    }
    
    private func storeChanges() {
        let currentConfiguration: [FrequentOperative] = sections.last?.items.compactMap {
            guard let section = $0 as? DraggableImageAndDescriptionViewModel, let directLink = DirectLinkTypeItem(rawValue: section.itemIdentifier) else { return nil }
            return FrequentOperative(directLink: directLink, isEnabled: section.switchState)
            } ?? []
        let input = SaveFrequentOperativeOptionsUseCaseInput(frequentOperatives: currentConfiguration)
        let useCase = useCaseProvider.savePersonalAreaFrequentOperativesUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, includeAllExceptions: false, queuePriority: .normal, onSuccess: { [weak self] (_) in
                self?.isGlobalPositionReloading = true
                self?.reloadGlobalPosition()
            }, onError: { [weak self] (_) in
                guard let strongSelf = self else { return }
                let ok = DialogButtonComponents(titled: strongSelf.stringLoader.getString("generic_button_accept")) {}
                Dialog.alert(title: nil, body: strongSelf.stringLoader.getString("generic_error_txt"),
                             withAcceptComponent: ok,
                             withCancelComponent: nil,
                             source: strongSelf.view)
        })
    }
    
    var actionTitle: LocalizedStylableText {
        return stringLoader.getString("displayOptions_button_saveChanges")
    }
    
    var title: String {
        return stringLoader.getString("toolbar_title_frequentOperative").text
    }
}
