//
//  UIViewController+SearchBarButton.swift
//  UI
//
//  Created by alvola on 24/02/2020.
//
import UIKit
import CoreFoundationLib

@objc public protocol NavigationBarWithSearchProtocol: AnyObject {
    var isSearchEnabled: Bool { get set }
    var searchButtonPosition: Int { get }
    @objc func searchButtonPressed()
}

public extension NavigationBarWithSearchProtocol where Self: UIViewController {
    func addSearch(tintColor: UIColor, searchText: String?) {
        let tagItem = 11202
        guard navigationItem.rightBarButtonItems?.filter({$0.tag == tagItem}).first == nil
        else { return }
        let barButton: UIBarButtonItem
        let action = #selector(searchButtonPressed)
        if let searchTextUnwrapped = searchText {
            let button = ImageAndTextButton()
                   button.set(title: searchTextUnwrapped,
                              image: "icnSearch",
                              target: self,
                              action: action,
                              tintColor: tintColor,
                              template: true)
                   button.sizeToFit()
                   barButton = UIBarButtonItem(customView: button)
        } else {
            barButton = UIBarButtonItem(
                image: Assets.image(named: "icnSearch")?.withRenderingMode(.alwaysTemplate),
                style: .plain,
                target: self,
                action: action
            )
            barButton.tintColor = tintColor
        }
        barButton.tag = tagItem
        barButton.accessibilityIdentifier = AccessibilityNavigation.icnSearch.rawValue
        barButton.accessibilityLabel = localized("generic_label_search")
        navigationItem.rightBarButtonItems?.insert(barButton, at: searchButtonPosition)
    }
}
