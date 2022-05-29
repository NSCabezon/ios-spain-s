//
//  LisboaSignatureViewController.swift
//  RetailClean
//
//  Created by Jose Carlos Estela Anguita on 02/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import Operative
import UI
import CoreFoundationLib

final class LisboaSignatureViewController: BaseViewController<LisboaSignaturePresenterProtocol> {
    override var isKeyboardDismisserActivated: Bool {
        return false
    }
    
    private weak var signatureViewController: SignatureViewController?
    
    override static var storyboardName: String {
        return "LisboaSignature"
    }
        
    override var progressBarBackgroundColor: UIColor? {
        return .sky30
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
        if !UIAccessibility.isVoiceOverRunning {
            setupNavigationBar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    func setupNavigationBar() {
        var navigationBarBuilder: NavigationBarBuilder
        if let headerKey = presenter.navigationBarTitle {
            navigationBarBuilder = NavigationBarBuilder(
                style: .sky,
                title: .titleWithHeader(titleKey: "toolbar_title_signing",
                                        header: .title(key: headerKey, style: .default)))
        } else {
            navigationBarBuilder = NavigationBarBuilder(
                style: .sky,
                title: .title(key: "toolbar_title_signing"))
        }
        navigationBarBuilder.setLeftAction(.back(action: #selector(didTapBack)))
        if self.presenter.showsHelpButton {
            navigationBarBuilder.setRightActions(.close(action: #selector(didTapClose)), .help(action: #selector(didTapHelp)) )
        } else {
            navigationBarBuilder.setRightActions(.close(action: #selector(didTapClose)))
        }
        navigationBarBuilder.build(on: self, with: nil)
    }
    
    func setupViews() {
        let signatureViewController: SignatureViewController = SignatureViewController(presenter: presenter)
        self.view.addSubview(signatureViewController.view)
        signatureViewController.view.translatesAutoresizingMaskIntoConstraints = false
        signatureViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        signatureViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        signatureViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        signatureViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(signatureViewController)
        signatureViewController.didMove(toParent: self)
        self.signatureViewController = signatureViewController
    }
    
    func setupAccessibility() {
        setupNavigationBar()
        self.accessibilityElements = {
            var elements: [Any] = []
            if let navigationBarElements = self.navigationController?.navigationBar.accessibilityElements {
                elements.append(contentsOf: navigationBarElements)
            }
            if let progress = self.navigationController?.view.subviews.first(where: { $0 is LisboaProgressView }) {
                elements.append(progress)
            }
            if let signatureViewControllerElements = self.signatureViewController?.accessibilityElements {
                elements.append(contentsOf: signatureViewControllerElements)
            }
            return elements
        }()
    }
    
    func reset() {
        self.signatureViewController?.reset()
    }
    
    func setPurpose(_ purpose: SignaturePurpose) {
        self.signatureViewController?.setPurpose(purpose)
    }
    
    @objc func didTapBack() {
        presenter.didTapBack()
    }
    
    @objc func didTapClose() {
        presenter.didTapClose()
    }
    
    @objc private func didTapHelp() {
        presenter.didSelectRememberSignature()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension LisboaSignatureViewController: OperativeStepViewProtocol {
    
    var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
}
