import QuickSetup

extension PersonalManagerModuleCoordinator: DefaultModuleLauncher {
    public func start() {
        self.start(.withoutManager)
    }
}
