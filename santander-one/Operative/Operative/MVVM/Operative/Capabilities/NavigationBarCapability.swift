//
//  NavigationBarCapability.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 19/1/22.
//

import Foundation
import UI
import OpenCombine
import CoreFoundationLib
import UIKit

/// A capability that adds the default navigation bar to our operative.
public final class DefaultNavigationBarCapability<Operative: ReactiveOperative>: Capability {
    
    public let operative: Operative
    private let navigationBarDependencies: NavigationBarExternalDependenciesResolver
    private let configuration: Configuration
    
    public init(operative: Operative, navigationBarDependencies: NavigationBarExternalDependenciesResolver, configuration: Configuration) {
        self.operative = operative
        self.navigationBarDependencies = navigationBarDependencies
        self.configuration = configuration
    }
    
    public func configure() {
        bindShowPrevious()
        bindShowNext()
    }
}

public extension DefaultNavigationBarCapability {
    
    typealias TitleForStep = (Operative.StepType) -> NavigationBarBuilder.Title
    typealias LeftActionForStep = (Operative.StepType) -> NavigationBarItemBuilder.LeftAction
    typealias RightActionsForStep = (Operative.StepType) -> [NavigationBarItemBuilder.RightAction]
    
    final class Builder {
        
        private var title: TitleForStep = { _ in return .none }
        private var leftAction: LeftActionForStep = { _ in return .none }
        private var rightActions: RightActionsForStep = { _ in return [] }
        private var faqs: [FaqsItemViewModel] = []
        
        public init() {
            
        }
        
        @discardableResult
        public func addTitle(_ title: @escaping TitleForStep) -> Builder {
            self.title = title
            return self
        }
        
        @discardableResult
        public func addLeftAction(_ leftAction: @escaping LeftActionForStep) -> Builder {
            self.leftAction = leftAction
            return self
        }
        
        @discardableResult
        public func addRightActions(_ rightActions: @escaping RightActionsForStep) -> Builder {
            self.rightActions = rightActions
            return self
        }
        
        @discardableResult
        public func addFaqs(_ faqs: [FaqsItemViewModel]) -> Builder {
            self.faqs = faqs
            return self
        }
        
        public func build() -> Configuration {
            return Configuration(title: title, leftAction: leftAction, rightActions: rightActions, faqs: faqs)
        }
    }
    
    struct Configuration {
        
        let title: TitleForStep
        let leftAction: LeftActionForStep
        let rightActions: RightActionsForStep
        let faqs: [FaqsItemViewModel]
        
        init(title: @escaping TitleForStep, leftAction: @escaping LeftActionForStep, rightActions: @escaping RightActionsForStep, faqs: [FaqsItemViewModel]) {
            self.title = title
            self.leftAction = leftAction
            self.rightActions = rightActions
            self.faqs = faqs
        }
    }
}

private extension DefaultNavigationBarCapability {
    
    func showNavigationBar(step: Operative.StepType, view: UIViewController) {
        let builder = NavigationBarItemBuilder(dependencies: navigationBarDependencies)
            .addTitle(configuration.title(step))
        addLeftAction(step: step, in: builder)
        addRightActions(step: step, in: builder)
        builder.build(on: view)
    }
    
    func addLeftAction(step: Operative.StepType, in builder: NavigationBarItemBuilder) {
        switch configuration.leftAction(step) {
        case .none:
            break
        case .back:
            builder.setLeftAction(.back, associatedAction: .closure(operative.back))
        }
    }
    
    func addRightActions(step: Operative.StepType, in builder: NavigationBarItemBuilder) {
        guard let viewController = operative.coordinator.navigationController?.topViewController else { return }
        configuration.rightActions(step).forEach { action in
            switch action {
            case .close:
                builder.addRightAction(.close, associatedAction: .closure(operative.finish))
            case .help:
                builder.addRightAction(.help, associatedAction: .closure({
                    FaqsViewData(items: self.configuration.faqs).show(in: viewController)
                }))
            case .menu, .search:
                break
            }
        }
    }
    
    func bindShowPrevious() {
        operative.stepsCoordinator
            .willShowPreviousPublisher
            .sink { [unowned self] result in
                self.showNavigationBar(step: result.step, view: result.view)
            }
            .store(in: &operative.subscriptions)
    }
    
    func bindShowNext() {
        operative.stepsCoordinator
            .willShowNextPublisher
            .sink { [unowned self] result in
                self.showNavigationBar(step: result.step, view: result.view)
            }
            .store(in: &operative.subscriptions)
    }
}
