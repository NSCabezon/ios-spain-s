//
//  OneNavigationBarCapability.swift
//  Operative
//
//  Created by Cristobal Ramos Laina on 8/2/22.
//

import Foundation
import UI
import OpenCombine
import CoreFoundationLib
import UIOneComponents

/// A capability that adds the default navigation bar to our operative.
public final class OneNavigationBarCapability<Operative: ReactiveOperative>: Capability {
    
    public let operative: Operative
    private let configuration: Configuration
    
    public init(operative: Operative, configuration: Configuration) {
        self.operative = operative
        self.configuration = configuration
    }
    
    public func configure() {
        bindShowPrevious()
        bindShowNext()
    }
}

public extension OneNavigationBarCapability {
    typealias TitleForStep = (Operative.StepType) -> NavigationBarBuilder.Title
    typealias TitleForStepString = (Operative.StepType) -> String
    typealias TitleImageForStep = (Operative.StepType) -> OneNavigationBarTitleImage?
    typealias TitleConfiguration = (Operative.StepType) -> LocalizedStylableTextConfiguration?
    typealias LeftActionForStep = (Operative.StepType) -> NavigationBarItemBuilder.LeftAction
    typealias RightActionsForStep = (Operative.StepType) -> [NavigationBarItemBuilder.RightAction]
    
    final class Builder {
        
        private var title: TitleForStepString = { _ in return "" }
        private var titleImage: TitleImageForStep = { _ in return nil }
        private var titleConfiguration: TitleConfiguration = { _ in return nil }
        private var rightActions: RightActionsForStep = { _ in return [] }
        private var leftAction: LeftActionForStep = { _ in return .back }
        private var faqs: [FaqsItemViewModel] = []
        private var style: OneNavigationBarStyle = .whiteWithRedComponents
        
        public init() {
            
        }
        
        @discardableResult
        public func addTitle(_ title: @escaping TitleForStepString) -> Builder {
            self.title = title
            return self
        }
        
        @discardableResult
        public func addTitleImage(_ titleImage: @escaping TitleImageForStep) -> Builder {
            self.titleImage = titleImage
            return self
        }
        
        @discardableResult
        public func addTitleConfiguration(_ titleConfiguration: @escaping TitleConfiguration) -> Builder {
            self.titleConfiguration = titleConfiguration
            return self
        }
        
        @discardableResult
        public func addRightActions(_ rightActions: @escaping RightActionsForStep) -> Builder {
            self.rightActions = rightActions
            return self
        }
        
        @discardableResult
        public func addLeftAction(_ leftAction: @escaping LeftActionForStep) -> Builder {
            self.leftAction = leftAction
            return self
        }
        
        @discardableResult
        public func addFaqs(_ faqs: [FaqsItemViewModel]) -> Builder {
            self.faqs = faqs
            return self
        }
        
        @discardableResult
        public func addStyle(_ style: OneNavigationBarStyle) -> Builder {
            self.style = style
            return self
        }
        
        public func build() -> Configuration {
            return Configuration(title: title,
                                 titleImage: titleImage,
                                 titleConfiguration: titleConfiguration,
                                 rightActions: rightActions,
                                 leftAction: leftAction,
                                 faqs: faqs,
                                 style: style)
        }
    }
    
    struct Configuration {
        
        let title: TitleForStepString
        let titleImage: TitleImageForStep
        let titleConfiguration: TitleConfiguration
        let rightActions: RightActionsForStep
        let leftAction: LeftActionForStep
        let faqs: [FaqsItemViewModel]
        let style: OneNavigationBarStyle
        
        init(title: @escaping TitleForStepString, titleImage: @escaping TitleImageForStep, titleConfiguration: @escaping TitleConfiguration, rightActions: @escaping RightActionsForStep, leftAction: @escaping LeftActionForStep, faqs: [FaqsItemViewModel], style: OneNavigationBarStyle) {
            self.title = title
            self.titleImage = titleImage
            self.titleConfiguration = titleConfiguration
            self.rightActions = rightActions
            self.leftAction = leftAction
            self.faqs = faqs
            self.style = style
        }
    }
}

private extension OneNavigationBarCapability {
    
    func showNavigationBar(step: Operative.StepType, view: UIViewController) {
        let builder = OneNavigationBarBuilder(configuration.style)
            .setTitle(withKey: configuration.title(step))
            .setTitleImage(withTitleImage: configuration.titleImage(step))
            .setTitleConfiguration(withConfiguration: configuration.titleConfiguration(step))
        switch configuration.leftAction(step) {
        case .back:
            _ = builder.setLeftAction(.back, customAction: { [weak self] in
                self?.operative.back()
            })
        default:
            break
        }
        addRightActions(step: step, in: builder)
        builder.build(on: view)
    }
    
    func addRightActions(step: Operative.StepType, in builder: OneNavigationBarBuilder) {
        guard let viewController = operative.coordinator.navigationController?.topViewController else { return }
        configuration.rightActions(step).forEach { action in
            switch action {
            case .close:
                _ = builder.setRightAction(.close, action: { [weak self] in
                    self?.operative.finish()
                })
            case .help:
                _ = builder.setRightAction(.help, action: { [weak self] in
                    guard let faqs = self?.configuration.faqs else { return }
                    FaqsViewData(items: faqs).show(in: viewController)
                })
            case .menu, .search:
                break
            }
        }
    }
    
    func bindShowPrevious() {
        operative.stepsCoordinator
            .willShowPreviousPublisher
            .sink { [weak self] result in
                self?.showNavigationBar(step: result.step, view: result.view)
            }
            .store(in: &operative.subscriptions)
    }
    
    func bindShowNext() {
        operative.stepsCoordinator
            .didShowNextPublisher
            .sink { [weak self] result in
                self?.showNavigationBar(step: result.step, view: result.view)
            }
            .store(in: &operative.subscriptions)
    }
}
