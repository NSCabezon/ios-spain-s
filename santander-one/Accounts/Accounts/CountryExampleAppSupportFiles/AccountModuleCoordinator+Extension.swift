import QuickSetup

extension AccountsModuleCoordinator: DefaultModuleLauncher {
    public func start() {
        self.start(.home)
    }
}
