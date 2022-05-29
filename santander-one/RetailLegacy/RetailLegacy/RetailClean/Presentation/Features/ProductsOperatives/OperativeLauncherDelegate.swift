protocol OperativeLauncherDelegate: class {
    var dependencies: PresentationComponent { get }
    var navigatorOperativeLauncher: OperativesNavigatorProtocol { get }
    var operativeDelegate: OperativeLauncherPresentationDelegate { get }
}
