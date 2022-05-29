//
//  EcommerceContainerView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public protocol EcommerceContainerViewProtocol: class {
    func didTapInUseKeyAccessView()
    func didFinishTimerInProgressView()
    func didPressChangeUser()
    func didPressUseAccessCode()
    func didTapBiometryIcon()
    func didTapOpinator(_ opinatorPath: String)
}

public protocol FintechNumberPadConfirmationProtocol: class {
    func confirmed(withAccesskey key: String)
    func confirmed(withType type: String, documentNumber: String, accessKey: String)
}

public final class EcommerceContainerView: XibView {
    @IBOutlet private weak var ticketView: EcommerceTicketView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var securePurchaseStackView: UIStackView!
    @IBOutlet private weak var firstStackViewToSafeAreaBotttomConstraint: NSLayoutConstraint!
    @IBOutlet weak var securePurchaseHeightConstraint: NSLayoutConstraint!
    weak var delegate: EcommerceContainerViewProtocol?
    weak var fintechDelegate: FintechNumberPadConfirmationProtocol?
    private var fintechContainerView: FintechContainerView?
    private var useKeyAccessView = EcommerceKeyAccessContentView()
    private var stackViewSpacing: CGFloat = 10.0
    private var secureStackViewHeight: CGFloat = 30.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ containerType: EcommerceTicketContentType) {
        self.ticketView.configView(containerType)
        self.configViewDetail(containerType)
    }
    
    func configView(_ containerType: FintechTPPConfirmationState) {
        self.configViewDetail(forState: containerType)
    }
}

private extension EcommerceContainerView {
    
    func setupView() {
        self.backgroundColor = .skyGray
        self.stackView.backgroundColor = .clear
        self.ticketView.drawShadow(offset: (0, 2), opacity: 0.5, color: .gray, radius: 4)
        self.ticketView.delegate = self
        self.useKeyAccessView.delegate = self
    }
    
    func configViewDetail(_ containerType: EcommerceTicketContentType) {
        self.removeArrangedSubviewsIfNeeded()
        switch containerType {
        case .ticket(let configuration):
            self.addUseKeyAccessContentView(showsCodeKeyButton: configuration.showsCodeKeyButton)
            self.addOpinatorView(configuration)
            self.addSecurePurchaseView(configuration)
        case .loading:
            self.addLoadingContentView()
        case .errorData:
           break
        }
    }
    
    func configViewDetail(forState state: FintechTPPConfirmationState) {
        if case let .home(authType, authStatus, paymentStatus, userName) = state {
            fintechContainerView?.removeFromSuperview()
            fintechContainerView = nil
            ticketView.configViewForFintechWith(authStatus,
                                                type: authType,
                                                paymentStatus: paymentStatus,
                                                userName: userName)
            switch authType {
            case .faceId, .fingerPrint:
                addUseKeyAccessContentView(showsCodeKeyButton: true)
            default:
                break
            }
            if case .identifying = paymentStatus {
                addUseKeyAccessContentView(showsCodeKeyButton: false)
            }
            return
        }
        if case let .error(reason) = state {
            fintechContainerView?.removeFromSuperview()
            fintechContainerView = nil
            ticketView.configView(.errorData(reason: reason))
            return
        }
        if case .success = state {
            ticketView.hide()
        }
        if fintechContainerView == nil {
            fintechContainerView = FintechContainerView()
            fintechContainerView?.delegate = self
            fintechContainerView?.translatesAutoresizingMaskIntoConstraints = false
            addSubview(fintechContainerView!)
            fintechContainerView?.fullFit()
        }
        fintechContainerView?.configViewDetail(state)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.stackView.arrangedSubviews.isEmpty {
            self.stackView.removeAllArrangedSubviews()
            self.stackView.spacing = 0
            self.firstStackViewToSafeAreaBotttomConstraint.isActive = true
            self.securePurchaseHeightConstraint.constant = 0.0
        }
        if !self.securePurchaseStackView.arrangedSubviews.isEmpty {
            self.securePurchaseStackView.removeAllArrangedSubviews()
        }
    }
    
    func addLoadingContentView() {
        let loadingContentView = EcommerceLoadingContentView()
        self.stackView.addArrangedSubview(loadingContentView)
        self.addFooterSecurityView()
    }
    
    func addUseKeyAccessContentView(showsCodeKeyButton: Bool) {
        useKeyAccessView.configView(showsCodeKeyButton)
        if !stackView.arrangedSubviews.contains(useKeyAccessView) {
            self.stackView.addArrangedSubview(useKeyAccessView)
        }
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceContainerView.baseView
        self.ticketView.accessibilityIdentifier = AccessibilityEcommerceContainerView.ticketView
    }
    
    func addSecurePurchaseView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        guard case .success = ticketConfiguration.purchaseStatus else {
            self.securePurchaseStackView.isHidden = true
            self.firstStackViewToSafeAreaBotttomConstraint.isActive = true
            return
        }
        self.addFooterSecurityView()
    }
    
    func addOpinatorView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        guard case .success = ticketConfiguration.purchaseStatus,
              let opinatorViewModel = ticketConfiguration.opinatorViewModel
        else {
            return
        }
        let opinatorView = OpinatorView()
        opinatorView.delegate = self
        opinatorView.setViewModel(opinatorViewModel)
        self.stackView.spacing = self.stackViewSpacing
        self.stackView.addArrangedSubview(opinatorView)
    }
    
    func addFooterSecurityView() {
        let view = EcommerceFooterSecurityView()
        self.firstStackViewToSafeAreaBotttomConstraint.isActive = false
        self.securePurchaseStackView.isHidden = false
        self.securePurchaseHeightConstraint.constant = self.secureStackViewHeight
        self.securePurchaseStackView.addArrangedSubview(view)
    }
}

extension EcommerceContainerView: DidTapInUseKeyAccessDelegate {
    public func didTapInUseKeyAccess() {
        delegate?.didTapInUseKeyAccessView()
    }
}

extension EcommerceContainerView: EcommerceTicketViewDelegate {
    public func didPressChangeUser() {
        delegate?.didPressChangeUser()
    }
    
    public func progressViewDidFinish() {
        delegate?.didFinishTimerInProgressView()
    }
    
    public func didPressUseAccessCode() {
        delegate?.didPressChangeUser()
    }
    
    public func didPressBiometryIcon() {
        delegate?.didTapBiometryIcon()
    }
}

extension EcommerceContainerView: FintechContainerViewDelegateProtocol {
    func numberPadConfirmation(withCode code: String) {
        fintechDelegate?.confirmed(withAccesskey: code)
    }
    
    func numberPadConfirmation(withType type: String, documentNumber: String, accessKey: String) {
        fintechDelegate?.confirmed(
            withType: type,
            documentNumber: documentNumber,
            accessKey: accessKey
        )
    }
}

extension EcommerceContainerView: OpinatorViewDelegate {
    public func didSelectOpinator(_ opinator: String) {
        delegate?.didTapOpinator(opinator)
    }
}
