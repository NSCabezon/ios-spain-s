protocol EnableOtpPushOperativeLauncher: class {
    func launchOtpPushOperative(device: OTPPushDevice?, withDelegate delegate: OperativeLauncherDelegate)
    func launchOtpPushOperative(delegate: OperativeLauncherDelegate)
}

extension EnableOtpPushOperativeLauncher {
    func launchOtpPushOperative(device: OTPPushDevice?, withDelegate delegate: OperativeLauncherDelegate) {
        let operativeData = EnableOtpPushOperativeData(isAnyDeviceRegistered: device != nil)
        launchOtpPushOperative(operativeData: operativeData, delegate: delegate)
    }
    
    func launchOtpPushOperative(delegate: OperativeLauncherDelegate) {
        let operativeData = EnableOtpPushOperativeData(isAnyDeviceRegistered: nil)
        launchOtpPushOperative(operativeData: operativeData, delegate: delegate)
    }
}

private extension EnableOtpPushOperativeLauncher {
    func launchOtpPushOperative(operativeData: EnableOtpPushOperativeData, delegate: OperativeLauncherDelegate) {
        let operative = EnableOtpPushOperative(dependencies: delegate.dependencies)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: false, container: container, delegate: delegate.operativeDelegate)
    }
}
