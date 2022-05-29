import Foundation

protocol ExtraordinaryContributionLauncher {
    func launchExtraordinaryContribution(pension: Pension?, delegate: OperativeLauncherDelegate)
}

extension ExtraordinaryContributionLauncher {
    
    func launchExtraordinaryContribution(pension: Pension?, delegate: OperativeLauncherDelegate) {
        let operative = ExtraordinaryContributionOperative(dependencies: delegate.dependencies)
        let operativeData = ExtraContributionPensionOperativeData(pension: pension)
        guard let container = delegate.navigatorOperativeLauncher.appendOperative(operative, dependencies: delegate.dependencies) else {
            return
        }
        container.saveParameter(parameter: operativeData)
        operative.start(needsSelection: pension == nil, container: container, delegate: delegate.operativeDelegate)
    }
}
