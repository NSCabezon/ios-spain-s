//
//  ProgressBarCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import UIOneComponents
import OpenCombine
import UI

/// A capability that adds the default progress bar to our operative.
public final class DefaultProgressBarCapability<Operative: ReactiveOperative>: Capability {
    public let operative: Operative
    private let progressBarType: ProgressBarType
    private let shouldShowProgress: (Operative.StepType) -> Bool
    let progressBar: SteppedProgressBar = SteppedProgressBar()
    
    public init(operative: Operative, progressBarType: ProgressBarType, shouldShowProgress: @escaping (Operative.StepType) -> Bool) {
        self.operative = operative
        self.progressBarType = progressBarType
        self.shouldShowProgress = shouldShowProgress
    }
}

extension DefaultProgressBarCapability {
    public func configure() {
        guard let navigationController = operative.coordinator.navigationController else { return }
        bindProgress()
        bindWillShowNext()
        bindWillShowPrevious()
        bindWillFinish()
        progressBar.isHidden = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.insertSubview(progressBar, belowSubview: navigationController.navigationBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor,
                                             constant: progressBar.frame.height),
            progressBar.leftAnchor.constraint(equalTo: navigationController.view.leftAnchor),
            progressBar.rightAnchor.constraint(equalTo: navigationController.view.rightAnchor)
        ])
        progressBar.configure(unfilledColor: .lightSanGray, filledColor: .bostonRed, progressBarType: progressBarType)
    }
}

private extension DefaultProgressBarCapability {
    func bindProgress() {
        // Update progressbar
        operative.stepsCoordinator.progressPublisher
            .dropFirst()
            .sink { [weak self] progress in
                self?.updateTotal(progress.total)
                self?.updateCurrent(progress.current)
            }
            .store(in: &operative.subscriptions)
    }
    
    func bindWillShowNext() {
        // Show progress when next is enabled
        operative.stepsCoordinator.willShowNextPublisher
            .filter { [weak self] result in
                self?.shouldShowProgress(result.step) ?? true
            }
            .sink { [weak self] _ in
                self?.showProgressBar()
            }
            .store(in: &operative.subscriptions)
        // Dismiss progress when previous is not enabled
        operative.stepsCoordinator.willShowNextPublisher
            .filter { [weak self] result in
                !(self?.shouldShowProgress(result.step) ?? true)
            }
            .sink { [weak self] _ in
                self?.dismissProgressBar()
            }
            .store(in: &operative.subscriptions)
    }
    
    func bindWillShowPrevious() {
        // Show progress when previous is enabled
        operative.stepsCoordinator.willShowPreviousPublisher
            .filter { [weak self] result in
                self?.shouldShowProgress(result.step) ?? true
            }
            .sink { [weak self] _ in
                self?.showProgressBar()
            }
            .store(in: &operative.subscriptions)
        // Dismiss progress when previous is not enabled
        operative.stepsCoordinator.willShowPreviousPublisher
            .filter { [weak self] result in
                !(self?.shouldShowProgress(result.step) ?? true)
            }
            .sink { [weak self] _ in
                self?.dismissProgressBar()
            }
            .store(in: &operative.subscriptions)
    }
    
    func bindWillFinish() {
        operative.stepsCoordinator.willFinishPublisher
            .sink { [weak self] in
                self?.dismissProgressBar()
                self?.progressBar.removeFromSuperview()
            }
            .store(in: &operative.subscriptions)
    }
    
    func updateCurrent(_ current: Int) {
        progressBar.go(to: current, animated: true)
    }
    
    func updateTotal(_ total: Int) {
        progressBar.setSteps(total, completion: {})
    }

    func showProgressBar() {
        progressBar.isHidden = false
    }
    
    func dismissProgressBar() {
        progressBar.isHidden = true
    }
}
