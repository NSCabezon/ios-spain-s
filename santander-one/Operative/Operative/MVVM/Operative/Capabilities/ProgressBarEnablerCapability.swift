import UI

public protocol ProgressBarEnablerCapability: Capability {
    func showProgressBar()
    func dismissProgressBar()
}

public extension ProgressBarEnablerCapability {
    func showProgressBar() {
        guard let progressBar = operative.coordinator.navigationController?.view.subviews.first(where: { $0 is SteppedProgressBar }) else { return }
        progressBar.isHidden = false
    }
    
    func dismissProgressBar() {
        guard let progressBar = operative.coordinator.navigationController?.view.subviews.first(where: { $0 is SteppedProgressBar }) else { return }
        progressBar.isHidden = true
    }
}
