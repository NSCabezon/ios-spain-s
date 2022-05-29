//
//  NavigationBarWithSearch.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/3/21.
//
import CoreFoundationLib
import Foundation

public protocol NavigationBarWithSearch {}

public extension NavigationBarWithSearch where Self: UIViewController {
    func addSearch(tintColor: UIColor, searchText: String?, position: Int, action: NavigationBarAction) {
        let tagItem = 11202
        guard navigationItem.rightBarButtonItems?.filter({$0.tag == tagItem}).first == nil
        else { return }
        let barButton: UIBarButtonItem
        if let searchTextUnwrapped = searchText {
            let button = ImageAndTextButton()
            switch action {
            case .selector(let selector):
                button.set(title: searchTextUnwrapped,
                           image: "icnSearch",
                           target: self,
                           action: selector,
                           tintColor: tintColor,
                           template: true
                )
            case .closure(let action):
                button.set(title: searchTextUnwrapped,
                           image: "icnSearch",
                           action: action,
                           tintColor: tintColor,
                           template: true
                )
            }
            button.sizeToFit()
            barButton = UIBarButtonItem(customView: button)
        } else {
            switch action {
            case .selector(let selector):
                barButton = UIBarButtonItem(
                    image: Assets.image(named: "icnSearch")?.withRenderingMode(.alwaysTemplate),
                    style: .plain,
                    target: self,
                    action: selector
                )
            case .closure(let action):
                barButton = UIBarButtonItem(
                    image: Assets.image(named: "icnSearch")?.withRenderingMode(.alwaysTemplate),
                    style: .plain,
                    action: action
                )
            }
            barButton.tintColor = tintColor
        }
        barButton.tag = tagItem
        barButton.accessibilityIdentifier = AccessibilityNavigation.icnSearch.rawValue
        barButton.accessibilityLabel = localized("generic_label_search")
        navigationItem.rightBarButtonItems?.insert(barButton, at: position)
    }
}
