enum MifidOperative {
    case pensionsExtraordinaryContribution
    case fundsSubscription
    case fundsTransfer
    case stocksBuy
    case stocksSell
}

protocol MifidLauncherNavigatorProtocol {
    var drawer: BaseMenuViewController { get }
    var presenterProvider: PresenterProvider { get }
    
    func launchMifid2(withContainer container: OperativeContainerProtocol, forOperative operative: MifidOperative, delegate: MifidContainerDelegate, stringLoader: StringLoader)
}

extension MifidLauncherNavigatorProtocol {
    func launchMifid2(withContainer container: OperativeContainerProtocol, forOperative operative: MifidOperative, delegate: MifidContainerDelegate, stringLoader: StringLoader) {
        guard let navigationController = drawer.currentRootViewController as? NavigationController, let source = navigationController.viewControllers.last else {
            return
        }
        
        let mifidContainer = MifidContainer(mifidOperative: operative, operativeContainer: container, delegate: delegate, sourceView: source, presenterProvider: presenterProvider, stringLoader: stringLoader)
        
        mifidContainer.start()
    }
}

class DefaultMifidLauncherNavigator {
    let drawer: BaseMenuViewController
    let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.drawer = drawer
        self.presenterProvider = presenterProvider
    }
}

extension DefaultMifidLauncherNavigator: MifidLauncherNavigatorProtocol {}
