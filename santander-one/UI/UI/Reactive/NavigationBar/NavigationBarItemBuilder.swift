//
//  NavigationBarItemBuilder.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//
import OpenCombine
import Foundation
import CoreFoundationLib

public class NavigationBarItemBuilder {
    
    private struct SearchAction {
        let action: NavigationBarAction
        let position: Int
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var style: NavigationBarBuilder.Style = .sky
    private var title: NavigationBarBuilder.Title = .none
    private var leftAction: NavigationBarBuilder.LeftAction = .none
    private var rightActions: [NavigationBarBuilder.RightAction] = []
    private let dependencies: Dependency
    private let viewModel: NavigationBarViewModel
    private var search: SearchAction?
    
    public enum LeftAction {
        case back
        case none
    }
    
    public enum RightAction {
        case menu
        case search(position: Int)
        case close
        case help
    }
    
    public init(dependencies: NavigationBarExternalDependenciesResolver) {
        self.dependencies = Dependency(external: dependencies)
        self.viewModel = self.dependencies.resolve()
    }
    
    @discardableResult
    public func addStyle(_ style: NavigationBarBuilder.Style) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func addTitle(_ title: NavigationBarBuilder.Title) -> Self {
        self.title = title
        return self
    }
    
    @available(*, deprecated, message: "Use the setLeftAction(_ action: LeftAction, associatedAction: NavigationBarAction) instead")
    public func addLeftAction(_ action: LeftAction, selector: Selector) -> Self {
        return setLeftAction(.back(action: .selector(selector)))
    }
    
    @available(*, deprecated, message: "Use the addRightAction(_ action: RightAction, associatedAction: NavigationBarAction) instead")
    public func addRightAction(_ action: RightAction, selector: Selector) -> Self {
        switch action {
        case .menu:
            return addRightAction(.menu(action: .selector(selector)))
        case .search(let position):
            return addSearchAction(.selector(selector), position: position)
        case .close:
            return addRightAction(.close(action: .selector(selector)))
        case .help:
            return addRightAction(.help(action: .selector(selector)))
        }
    }
    
    @discardableResult
    public func setLeftAction(_ action: LeftAction, associatedAction: NavigationBarAction) -> Self {
        switch action {
        case .none:
            self.leftAction = .none
        case .back:
            self.leftAction = .back(action: associatedAction)
        }
        return self
    }
    
    @discardableResult
    public func addRightAction(_ action: RightAction, associatedAction: NavigationBarAction) -> Self {
        switch action {
        case .close:
            return addRightAction(.close(action: associatedAction))
        case .menu:
            return addRightAction(.menu(action: associatedAction))
        case .help:
            return addRightAction(.help(action: associatedAction))
        case .search(position: let position):
            return addSearchAction(associatedAction, position: position)
        }
    }
    
    public func build(on view: UIViewController) {
        let builder = NavigationBarBuilder(style: style, title: title)
            .setLeftAction(leftAction)
        builder.setRightActions(rightActions)
        viewModel.loadMenuItems()
        viewModel.state
            .case(NavigationBarState.menuLoaded)
            .sink { [weak self] items in
                builder.build(on: view, with: items.configuration)
                guard items.isSearchEnable,
                      let position = self?.search?.position,
                      let action = self?.search?.action else { return }
                builder.addSearch(
                    on: view,
                    searchPosition: position,
                    configuration: items.configuration,
                    action: action
                )
            }.store(in: &subscriptions)
    }
}

private extension NavigationBarItemBuilder {
    struct Dependency: NavigationBarDependenciesResolver {
        var external: NavigationBarExternalDependenciesResolver
    }
    
    func setLeftAction(_ action: NavigationBarBuilder.LeftAction) -> Self {
        leftAction = action
        return self
    }
    
    func addRightAction(_ action: NavigationBarBuilder.RightAction) -> Self {
        if let actionIndex = rightActions
            .firstIndex(where: { $0.uniqueIdentifier == action.uniqueIdentifier }) {
            rightActions[actionIndex] = action
        } else {
            rightActions.append(action)
        }
        return self
    }
    
    func addSearchAction(_ action: NavigationBarAction, position: Int) -> Self {
        search = SearchAction(action: action, position: position)
        return self
    }
}
