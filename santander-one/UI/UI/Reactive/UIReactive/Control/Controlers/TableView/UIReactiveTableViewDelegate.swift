//
//  UITableView+Combine.swift
//  OpenKit
//
//  Created by Juan Carlos López Robles on 3/14/22.
//

import UIKit
import Foundation
import OpenCombine
import CoreFoundationLib

public enum UITableViewDelegateState: State {
    case willDisplay(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
    case willDisplayHeaderView(tableView: UITableView, view: UIView, section: Int)
    case willDisplayFooterView(tableView: UITableView, view: UIView, section: Int)
    case willBeginEditingRowAt(tableView: UITableView, indexPath: IndexPath)
    case didEndDisplaying(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
    case didEndDisplayingHeaderView(tableView: UITableView, view: UIView, section: Int)
    case didEndDisplayingFooterView(tableView: UITableView, view: UIView, section: Int)
    case didHighlightRowAt(tableView: UITableView, indexPath: IndexPath)
    case didUnhighlightRowAt(tableView: UITableView, indexPath: IndexPath)
    case didSelectRowAt(tableView: UITableView, indexPath: IndexPath)
    case didDeselectRowAt(tableView: UITableView, indexPath: IndexPath)
    case didEndEditingRowAt(tableView: UITableView, indexPath: IndexPath?)
    case accessoryButtonTappedForRowWith(tableView: UITableView, indexPath: IndexPath)
}

public final class UIReactiveTableViewDelegate: NSObject, UITableViewDelegate {
    private let subject = PassthroughSubject<UITableViewDelegateState, Never>()
    
    public var statePublisher: AnyPublisher<UITableViewDelegateState, Never> {
        subject.eraseToAnyPublisher()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        subject.send(.willDisplay(tableView: tableView, cell: cell, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        subject.send(.willDisplayHeaderView(tableView: tableView, view: view, section: section))
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        subject.send(.willDisplayFooterView(tableView: tableView, view: view, section: section))
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        subject.send(.willBeginEditingRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        subject.send(.didEndDisplaying(tableView: tableView, cell: cell, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        subject.send(.didEndDisplayingHeaderView(tableView: tableView, view: view, section: section))
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        subject.send(.didEndDisplayingFooterView(tableView: tableView, view: view, section: section))
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        subject.send(.didHighlightRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        subject.send(.didUnhighlightRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        subject.send(.didSelectRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        subject.send(.didDeselectRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        subject.send(.didEndEditingRowAt(tableView: tableView, indexPath: indexPath))
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        subject.send(.accessoryButtonTappedForRowWith(tableView: tableView, indexPath: indexPath))
    }
}
