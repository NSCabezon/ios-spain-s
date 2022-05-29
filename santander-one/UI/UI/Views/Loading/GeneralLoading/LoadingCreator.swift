//
//  LoadingCreator.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 19/11/2020.
//

import Foundation
import CoreFoundationLib

public class LoadingCreator {
    private static weak var loadingController: LoadingViewController?
    
    public static func createAndShowLoading(info: LoadingInfo) -> LoadingActionProtocol {
        let loadingViewController = LoadingViewController()
        loadingViewController.showLoading(info: info)
        return loadingViewController
    }
    
    public static func showGlobalLoading(info: LoadingInfo, controller: UIViewController? = nil) {
        let loadingViewController = LoadingViewController()
        loadingViewController.showLoading(info: info)
        setCurrentLoadingController(loadingViewController)
    }

    public static func isCurrentlyLoadingShowing() -> Bool {
        return self.loadingController != nil
    }
    
    public static func showGlobalLoading(loadingText: LoadingText? = nil, controller: UIViewController? = nil, completion: (() -> Void)? = nil) {
        guard !isCurrentlyLoadingShowing() else {
            self.update(loadingText: loadingText, completion: completion)
            return
        }
        guard let source = controller ?? UIApplication.topViewController() else {
            return
        }
        let type = LoadingViewType.onScreen(controller: source, completion: completion)
        let info = LoadingInfo(type: type, loadingText: loadingText, placeholders: nil, topInset: nil, style: .global)
        let loadingViewController = LoadingViewController()
        loadingViewController.showLoading(info: info)
        setCurrentLoadingController(loadingViewController)
    }
    
    public static func hideGlobalLoading(completion: (() -> Void)? = nil) {
        guard let loadingController = loadingController else {
            completion?()
            return
        }
        loadingController.hideLoading(completion: completion)
        self.loadingController = nil
    }
    
    public static func setLoadingText(loadingText: LoadingText) {
        if let loadingContr = loadingController {
            loadingContr.setText(text: loadingText)
        }
    }
    
    public static func setPlaceholder(placeholder: [Placeholder], topInset: CGFloat, background: UIColor? = nil) {
        if let loadingContr = loadingController {
            loadingContr.setPlaceholder(placeholder: placeholder, topInset: topInset)
        }
    }
    
    private static func setCurrentLoadingController(_ currentLoadingViewController: LoadingViewController) {
        if loadingController != nil {
            hideGlobalLoading()
        }
        loadingController = currentLoadingViewController
    }
}
private extension LoadingCreator {
    static func update(loadingText: LoadingText?, completion: (() -> Void)?) {
        if let loadingText = loadingText {
            self.loadingController?.setText(text: loadingText)
        }
        completion?()
    }
}
