import QuickSetup

extension TransferModuleCoordinator: DefaultModuleLauncher {
    public func start() {
        self.start(.home)
    }
}
