//
//  EmptyPurchasesViewController.swift
//  Ecommerce
//
//  Created by Alvaro Royo on 29/3/21.
//

import UI
import CoreFoundationLib

public protocol EcommerceEmptyPurchasesProtocol: AnyObject {
    func hideOffer(_ hidden: Bool)
    func showSecureDevice(_ viewModel: EcommerceSecureDeviceViewModel)
    func showTopAlert(text: LocalizedStylableText)
}

public protocol EcommerceSecureDeviceDelegate: AnyObject {
    func didTapRegisterSecureDevice()
}

public class EmptyPurchasesViewController: UIViewController {
    
    private var emptyView: EcommerceEmptyPurchasesView!
    private var presenter: EmptyPurchasesPresenterProtocol
    public weak var closeDelegate: EmptyPurchaseCloseDelegate?
    
    public init(presenter: EmptyPurchasesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = EcommerceEmptyPurchasesView(frame: .zero)
        emptyView.buttonAction = { [weak self] in
            self?.presenter.showEcommerceLocation()
        }
        view.addSubview(emptyView)
        emptyView.fullFit()
        presenter.viewDidLoad()
    }
    
    func hideFooter() {
        self.emptyView.footerView.isHidden = true
    }
    
    public func configureWithSecureDevice(_ viewModel: EcommerceSecureDeviceViewModel) {
        self.presenter.setSecureDevice(viewModel: viewModel)
    }
}

extension EmptyPurchasesViewController: EcommerceEmptyPurchasesProtocol {
    public func hideOffer(_ hidden: Bool) {
        emptyView.buttonContainer.isHidden = hidden
    }
    
    public func showSecureDevice(_ viewModel: EcommerceSecureDeviceViewModel) {
        self.emptyView.showSecureDevice(viewModel)
        self.emptyView.footerView.isHidden = true
        self.emptyView.secureDeviceDelegate = self
    }
    
    public func showTopAlert(text: LocalizedStylableText) {
        TopAlertController.setup(TopAlertView.self).showAlert(text, alertType: .message, duration: 4)
    }
}

extension EmptyPurchasesViewController: EcommerceSecureDeviceDelegate {
    public func didTapRegisterSecureDevice() {
        closeDelegate?.didTapInDismiss({
            Async.after(seconds: 1.0) {
                self.presenter.didTapRegisterSecureDevice()
            }
        })
    }
}
