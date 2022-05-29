//
//  File.swift
//  Ecommerce
//
//  Created by César González Palomino on 24/05/2021.
//

import UIKit

protocol FintechContainerViewDelegateProtocol: class {
    func numberPadConfirmation(withCode code: String)
    func numberPadConfirmation(withType type: String, documentNumber: String, accessKey: String)
}

final class FintechContainerView: UIView {
    
    weak var delegate: FintechContainerViewDelegateProtocol?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .skyGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var loadingView: FintechLoadingView = {
        let view = FintechLoadingView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var successView: FintechSuccessView = {
        let view = FintechSuccessView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var unrememberedUserLoginView: FintechUnrememberedUserLoginView = {
        let view = FintechUnrememberedUserLoginView(frame: .zero)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rememberedUserViewLoginView: FintechRememberedUserViewLoginView = {
        let view = FintechRememberedUserViewLoginView(frame: .zero)
        view.setPadDelegate(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configViewDetail(_ containerType: FintechTPPConfirmationState) {
        _ = subviews.compactMap { $0.removeFromSuperview() }
        switch containerType {
        case .home, .error:
            break
        case .loading:
            addSubview(loadingView)
            loadingView.fullFit()
        case .success:
            setupSuccessView()
        case .identifyUnremembered:
            addSubview(unrememberedUserLoginView)
            unrememberedUserLoginView.fullFit()
        case .identifyRemembered:
            addSubview(rememberedUserViewLoginView)
            rememberedUserViewLoginView.fullFit()
        }
    }
    
    private func setupSuccessView() {
        addSubview(successView)
        successView.fullFit()
        let view = EcommerceFooterSecurityView()
        view.translatesAutoresizingMaskIntoConstraints = false
        successView.addSubview(view)
        view.bottomAnchor.constraint(equalTo: successView.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: successView.trailingAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: successView.leadingAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}

extension FintechContainerView: EcommerceNumberPadLoginViewDelegate {
    func didTapOnOK(withMagic magic: String) {
        delegate?.numberPadConfirmation(withCode: magic)
    }
}

extension FintechContainerView: FintechUnrememberedUserLoginViewDelegate {
    func confirmed(withType type: String, documentNumber: String, accessKey: String) {
        delegate?.numberPadConfirmation(withType: type, documentNumber: documentNumber, accessKey: accessKey)
    }
}
