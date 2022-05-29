protocol StocksAlertsConfigurationLauncher {
    var stocksAlertsConfigurationLauncherNavigator: StocksAlertsConfigurationLauncherNavigatorProtocol { get }
}

extension StocksAlertsConfigurationLauncher {
    
    func goToAlertsConfiguration() {
        stocksAlertsConfigurationLauncherNavigator.goToLanding()
    }
}
