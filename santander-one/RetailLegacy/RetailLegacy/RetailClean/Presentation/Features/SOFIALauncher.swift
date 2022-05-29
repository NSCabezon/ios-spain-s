protocol SOFIALauncher {
    var sofiaLauncherNavigator: SOFIALauncherNavigatorProtocol { get }
}

extension SOFIALauncher {
    
    func showSOFIA() {
        sofiaLauncherNavigator.goToLanding()
    }
}
