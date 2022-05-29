protocol CardOptionLauncherType {
    var dependencies: PresentationComponent { get }
    var errorHandler: GenericPresenterErrorHandler { get }
    var navigatorLauncher: OperativesNavigatorProtocol { get }
}
