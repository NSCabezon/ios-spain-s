import CoreFoundationLib

class PushMailBoxPresenter<Navigator: PushMailBoxNavigatorProtocol>: TabContainerPresenter<Navigator> {
    private let listOptions: [InboxTabList]
    private var currentOption: InboxTabList
    
    init(_ listOption: [InboxTabList], currentOption: InboxTabList, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: Navigator) {
        self.listOptions = listOption
        self.currentOption = currentOption
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_mailbox")
        
        setTabs(optionSelected: currentOption)
    }
    
    private func setTabs(optionSelected: InboxTabList) {
        var options = [(String?, LocalizedStylableText)]()
        for option in listOptions {
            let presenter = navigator.getPresenter(option: option)
            options.append((presenter.tabIconKey, presenter.tabTitle))
        }
        view.setTabs(options)
        
        currentOption = optionSelected
        setCurrentViewController(option: optionSelected)
        view.tabControlView.selectedOption = optionSelected.rawValue
    }
    
    func setCurrentViewController(option: InboxTabList) {
        if let lastPresenter = lastPresenter {
            view.remove(lastPresenter.viewController)
        }
        
        let nextPresenter = navigator.getPresenter(option: option)
        lastPresenter = nextPresenter
        view.setViewController(nextPresenter.viewController)
    }
    
    override func didSelectListOption(_ option: Int) {
        let newOption = listOptions[option]
        if currentOption.rawValue != newOption.rawValue {
            setCurrentViewController(option: newOption)
            
            currentOption = newOption
        }
    }
}

extension PushMailBoxPresenter: Presenter {}
