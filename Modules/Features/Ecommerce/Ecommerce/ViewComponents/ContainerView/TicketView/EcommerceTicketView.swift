//
//  EcommerceBaseTicketView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 16/2/21.
//

import UIKit
import UI
import ESCommons
import CoreFoundationLib

public protocol EcommerceTicketViewDelegate: class {
    func progressViewDidFinish()
    func didPressUseAccessCode()
    func didPressChangeUser()
    func didPressBiometryIcon()
}

public final class EcommerceTicketView: XibView {
    
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var baseTicketView: UIView!
    @IBOutlet public weak var ticketStackView: UIStackView!
    @IBOutlet private weak var bottomImageView: UIImageView!
    
    weak var delegate: EcommerceTicketViewDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ containerType: EcommerceTicketContentType) {
        self.removeArrangedSubviewsIfNeeded()
        switch containerType {
        case .ticket(let configuration):
            self.addTicketView(configuration)
        case .errorData(let reason):
            self.addErrorView(reason: reason)
        case .loading:
            self.addLoadingView()
        }
    }
    
    func configViewForFintechWith(_ status: EcommerceAuthStatus,
                                  type: EcommerceAuthType,
                                  paymentStatus: EcommercePaymentStatus?,
                                  userName: String?) {
        self.removeArrangedSubviewsIfNeeded()
        let view = FintechHomeView(frame: .zero)
        view.setStatus(status, type: type, paymentStatus: paymentStatus)
        if let payment = paymentStatus {
            view.setPaymentStatus(payment)
        }
        view.setUsername(userName)
        view.setDelegate(self)
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func hide() {
        self.removeArrangedSubviewsIfNeeded()
        topImageView.isHidden = true
        bottomImageView.isHidden = true
    }
}

private extension EcommerceTicketView {
    func setupView() {
        self.setImages()
        self.setTicketColors()
        self.setAccessibilityIds()
    }
    
    func setImages() {
        let teethTicketImage = Assets.image(named: "teethTicketImage")
        self.setTopTicketImage(teethTicketImage)
        self.setBottomTicketImage(teethTicketImage)
    }
    
    func setTopTicketImage(_ image: UIImage?) {
        self.topImageView.transform = topImageView.transform.rotated(by: CGFloat(Double.pi))
        self.topImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setBottomTicketImage(_ image: UIImage?) {
        self.bottomImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setTicketColors() {
        self.backgroundColor = .clear
        self.ticketStackView.backgroundColor = .clear
        self.baseTicketView.backgroundColor = .white
        self.topImageView.tintColor = .white
        self.bottomImageView.tintColor = .white
    }
    
    // MARK: - Configure StackView content
    func addTicketView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        self.addDateView(ticketConfiguration)
        self.addSeparator()
        self.addField(ticketConfiguration)
        self.addSeparator()
        if let statusView = ticketConfiguration.purchaseStatus {
            self.addPurchaseStatusView(statusView)
        } else {
            // self.addProgressView(ticketConfiguration) // Deleted the progressView temporally
            self.addConfirmTypeView(ticketConfiguration)
        }
    }
    
    func addErrorView(reason: String?) {
        let view = EcommerceTicketErrorView()
        if let reason = reason {
            view.updateError(reason: reason)
        }
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addLoadingView() {
        let view = EcommerceTicketLoadingView()
        self.ticketStackView.addArrangedSubview(view)
    }
    
    // MARK: - addTicketView(_:) methods
    func addDateView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        let view = EcommerceDateView()
        view.configView(ticketConfiguration.viewModel)
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addSeparator() {
        let view = EcommerceSeparatorView()
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addField(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        let view = EcommerceField()
        view.configView(ticketConfiguration.viewModel)
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addPurchaseStatusView(_ purchaseStatus: EcommercePaymentStatus) {
        let view = PurchaseStatusView()
        view.configView(purchaseStatus)
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addProgressView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        guard let time = ticketConfiguration.viewModel.time else {
            return
        }
        let view = EcommerceProgressView()
        view.delegate = self
        view.configView(time)
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func addConfirmTypeView(_ ticketConfiguration: EcommerceTicketContainerConfiguration) {
        let view = EcommerceConfirmTypeView()
        view.configView(ticketConfiguration.confirmType, status: ticketConfiguration.confirmStatus)
        view.biometryIconAction = {
            self.delegate?.didPressBiometryIcon()
        }
        self.ticketStackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.ticketStackView.arrangedSubviews.isEmpty {
            self.ticketStackView.removeAllArrangedSubviews()
        }
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceTicketView.baseTicket
        self.topImageView.accessibilityIdentifier = AccessibilityEcommerceTicketView.topImage
        self.ticketStackView.accessibilityIdentifier = AccessibilityEcommerceTicketView.stackContainer
        self.bottomImageView.accessibilityIdentifier = AccessibilityEcommerceTicketView.bottomImage
    }
}

extension EcommerceTicketView: EcommerceProgressViewDelegate {
    public func progressViewDidFinish() {
        delegate?.progressViewDidFinish()
    }
}

extension EcommerceTicketView: FintechHomeViewDelegate {
    
    func didPressChangeUser() {
        delegate?.didPressChangeUser()
    }
    
    func didPressBiometryIcon() {
        delegate?.didPressBiometryIcon()
    }
    
    func didPressUseAccessCode() {
        delegate?.didPressUseAccessCode()
    }
}
