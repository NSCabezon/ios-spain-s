import CoreFoundationLib
protocol ManagerProfileProtocol { }

class PersonalManagerContainerPresenter: PrivatePresenter<PersonalManagerContainerViewController, PersonalManagerNavigatorProtocol, PersonalManagerContainerPresenterProtocol>, PersonalManagerPageViewProtocol, PersonalManagerContainerPresenterProtocol {

    var isPageControlVisible: Bool?
    
    var pageControlTitles: PageControlTitleConfig {
        return (stringLoader.getString("manager_tab_personal"), stringLoader.getString("manager_tab_office"))
    }
    
    var title: LocalizedStylableText {
        return stringLoader.getString("toolbar_title_manager")
    }

    // MARK: - TrackerManager

    override var screenId: String? {
        return nil
    }
    
    //TODO: (EMMA_REPLACE) replaces emma event IDs for the targes ids
    let managerEventID = "e4d77ec3b0f72c2308107a600a74a09e"
    
    override var emmaScreenToken: String? {
        return TrackerPagePrivate.GenericManager(managerEventID: managerEventID).emmaToken
    }

    // MARK: -

    private var officeManagerList: ManagerList?
    private var personalManagerList: ManagerList?

    func currentPosition(at index: Int) {
        view.managerPageControl.pageIndicator(at: index)
    }

    override func loadViewData() {
        setBarButtons()
        getManagers { [weak self] in
            self?.getManagersSuccess()
        }
    }
    
    // MARK: - Private

    private func getManagers(completion: @escaping () -> Void) {
        
        hasAnyManager { (hasAny) in
            if !hasAny {
                completion()
            } else {
                self.getPersonalManager {
                    self.getOfficeManagers {
                        completion()
                    }
                }
            }
        }
    }
    
    private func getManagersSuccess() {
        self.view.managerPageControl.delegate = self
        let pages = buildPages()
        self.view.addPages(pages: pages)
    }

    private func hasAnyManager(completion: @escaping (Bool) -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.getHasAnyManagerUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { (manager) in
            completion(manager.hasAny)
        })
    }

    private func getOfficeManagers(completion: @escaping () -> Void) {
        UseCaseWrapper(with: dependencies.useCaseProvider.getGetOfficeManagersUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            
            guard let strongSelf = self else { return }
            strongSelf.officeManagerList = response.managerList

            completion()
        })
    }

    private func getPersonalManager(completion: @escaping () -> Void) {
        UseCaseWrapper(with: self.dependencies.useCaseProvider.getGetPersonalManagersUseCase(),
                       useCaseHandler: self.dependencies.useCaseHandler,
                       errorHandler: self.genericErrorHandler,
                       onSuccess: { [weak self](personalManager) in

                        guard let strongSelf = self else { return }
                        strongSelf.personalManagerList = personalManager.managerList

                        completion()
        })
    }

    private func buildPages() -> [ManagerProfileProtocol] {
        var managerViews = [ManagerProfileProtocol]()

        if let personalManagersPage = buildPersonalManagersPage() {
            managerViews.append(personalManagersPage)
        }

        if let officeManagersPage = buildOfficeManagersPage() {
            managerViews.append(officeManagersPage)
        }

        if managerViews.isEmpty {
            self.isPageControlVisible = false
            if let emptyPage = buildEmptyPage() {
                managerViews.append(emptyPage)
            }
        } else {
            self.isPageControlVisible = true
        }

        return managerViews
    }

    private func buildOfficeManagersPage() -> ManagerProfileProtocol? {
        guard let managers = officeManagerList?.managers else {
            return nil
        }
        if managers.isEmpty == true {
            let factory = PersonalManagerFactory(typeManager: .withoutOfficeManager,
                                                 managers: nil,
                                                 otherManagers: personalManagerList?.managers,
                                                 emptyViewConfig: nil,
                                                 dependencies: dependencies)
            return factory.makeViews()
        } else {
            let factory = PersonalManagerFactory(typeManager: .withOfficeManager,
                                                 managers: managers,
                                                 otherManagers: personalManagerList?.managers,
                                                 emptyViewConfig: nil,
                                                 dependencies: dependencies)
            return factory.makeViews()
        }
    }

    private func buildPersonalManagersPage() -> ManagerProfileProtocol? {
        guard let managers = personalManagerList?.managers else {
            return nil
        }

        if managers.isEmpty == true {
            let factory = PersonalManagerFactory(typeManager: .withoutPersonalManager,
                                                 managers: nil,
                                                 otherManagers: officeManagerList?.managers,
                                                 emptyViewConfig: false,
                                                 dependencies: dependencies)
            return factory.makeViews()
        } else {
            let factory = PersonalManagerFactory(typeManager: .withPersonalManager,
                                                 managers: managers,
                                                 otherManagers: officeManagerList?.managers,
                                                 emptyViewConfig: false,
                                                 dependencies: dependencies)
            return factory.makeViews()
        }

    }

    private func buildEmptyPage() -> ManagerProfileProtocol? {
        let factory = PersonalManagerFactory(typeManager: .withoutManager,
                                             managers: nil,
                                             otherManagers: nil,
                                             emptyViewConfig: true,
                                             dependencies: dependencies)
        return factory.makeViews()
    }

}

extension PersonalManagerContainerPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension PersonalManagerContainerPresenter: PersonalManagerPageControlDelegate {
    
    func didSelected(at index: Int) -> Bool {
        return view.personalManagerPageViewController.selectedViewController(view.pages[index], direction: index < 1 ? .reverse : .forward)
    }
}
