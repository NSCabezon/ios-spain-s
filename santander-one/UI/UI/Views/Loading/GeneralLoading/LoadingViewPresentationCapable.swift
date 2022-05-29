//
//  LoadingViewPresentationCapable.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 16/01/2020.
//

import Foundation
import CoreFoundationLib
import OpenCombine

public protocol LoadingViewPresentationCapable {
    func showLoadingPublisher() -> AnyPublisher<Void, Never>
    func dismissLoadingPublisher() -> AnyPublisher<Void, Never>
    func showLoading()
    func showLoading(completion: (() -> Void)?)
    func showLoading(title: LocalizedStylableText, completion: @escaping () -> Void)
    func showLoading(title: LocalizedStylableText, subTitle: LocalizedStylableText, completion: @escaping () -> Void)
    func dismissLoading(completion: (() -> Void)?)
    func dismissLoading()
    var associatedLoadingView: UIViewController { get }
}

public extension LoadingViewPresentationCapable where Self: UIViewController {
    
    var associatedLoadingView: UIViewController {
        return self
    }
}

extension LoadingViewPresentationCapable {
    
    public func showLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Future { promise in
            showLoading {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    public func dismissLoadingPublisher() -> AnyPublisher<Void, Never> {
        return Future { promise in
            dismissLoading {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    public func showLoading() {
        showLoading(title: localized("generic_popup_loadingContent"), subTitle: localized("loading_label_moment"), completion: {})
    }
    
    public func showLoading(completion: (() -> Void)?) {
        showLoading(title: localized("generic_popup_loadingContent"), subTitle: localized("loading_label_moment"), completion: completion ?? {})
    }
    
    public func showLoading(title: LocalizedStylableText, completion: @escaping () -> Void) {
        showLoading(title: title, subTitle: localized("loading_label_moment"), completion: completion)
    }
    
    public func showLoading(title: LocalizedStylableText, subTitle: LocalizedStylableText, completion: @escaping () -> Void) {
        let loadingText = LoadingText(title: title, subtitle: subTitle)
        if LoadingCreator.isCurrentlyLoadingShowing() {
            LoadingCreator.setLoadingText(loadingText: loadingText)
            completion()
        } else {
            LoadingCreator.showGlobalLoading(loadingText: loadingText, controller: associatedLoadingView, completion: completion)
        }
    }
    
    public func dismissLoading(completion: (() -> Void)?) {
        LoadingCreator.hideGlobalLoading(completion: completion)
    }
    
    public func dismissLoading() {
        LoadingCreator.hideGlobalLoading(completion: nil)
    }
    
    public func setLoadingText(_ loadingText: LoadingText) {
        LoadingCreator.setLoadingText(loadingText: loadingText)
    }
    
    public func setPlaceholder(_ placeholder: [Placeholder], topInset: CGFloat, background: UIColor? = nil) {
        LoadingCreator.setPlaceholder(placeholder: placeholder, topInset: topInset, background: background)
    }
    
    public func showLoadingWithLoading(info: LoadingInfo) {
        LoadingCreator.showGlobalLoading(info: info, controller: associatedLoadingView)
    }
    
    public func showLoadingOnViewWithLoading(info: LoadingInfo) {
        LoadingCreator.createAndShowLoading(info: info)
    }
}
