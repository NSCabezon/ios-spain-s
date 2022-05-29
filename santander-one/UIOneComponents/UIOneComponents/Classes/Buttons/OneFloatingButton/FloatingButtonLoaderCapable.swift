//
//  FloatingButtonLoaderCapable.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 25/1/22.
//

import UI

public protocol FloatingButtonLoaderCapable: AnyObject {
    var oneFloatingButton: OneFloatingButton { get }
    var loadingView: UIView? { get set }
    
    func showLoading()
    func hideLoading()
}

public extension LoadingViewPresentationCapable where Self: FloatingButtonLoaderCapable {
    
    func showLoading() {
        if self.loadingView == nil {
            self.prepareLoadingView()
        }
        self.loadingView?.isHidden = false
        self.oneFloatingButton.setLoadingStatus(.loading)
    }
    
    func hideLoading() {
        self.loadingView?.isHidden = true
        self.oneFloatingButton.setLoadingStatus(.ready)
    }
    
    func prepareLoadingView() {
        let view = UIView()
        view.frame = UIApplication.shared.keyWindow?.frame ?? CGRect()
        UIApplication.shared.keyWindow?.addSubview(view)
        view.backgroundColor = .white
        view.alpha = 0.6
        view.isHidden = true
        self.loadingView = view
    }
}
