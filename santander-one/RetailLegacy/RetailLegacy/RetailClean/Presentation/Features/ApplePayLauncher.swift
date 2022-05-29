protocol ApplePayLauncher {
    var dependencies: PresentationComponent { get }
}

extension ApplePayLauncher {
    
    func goToApplePay() {
        dependencies.navigatorProvider.applePayLauncherNavigator.goToLanding()
    }
}
