//
//  ApplePayEnrollmentViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation
import UIKit
import UI

protocol ApplePayEnrollmentViewProtocol: AnyObject {
    func setViewModel(_ viewModel: PlasticCardViewModel)
    func setOfferViewModel(_ viewModel: ApplePayOfferViewModel?)
    func showApplaPaySuccess()
    func showAddToApplePay()
}

final class ApplePayEnrollmentViewController: UIViewController {
    private let presenter: ApplePayEnrollmentPresenterProtocol
    private let bottomBar = CardBoardingTabBar(frame: .zero)
    private let addApplePayView = AddApplePayView(frame: .zero)
    private let successApplePayEnrollment = SuccessAppleEnrollmentView(frame: .zero)
    var isFirstStep: Bool = false

    init(nibName: String?, bundle: Bundle?, presenter: ApplePayEnrollmentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addBottomView()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    private func setNavigationBar() {
        let builder = NavigationBarBuilder(style: .white, title: .none)
        builder.build(on: self, with: nil)
    }
    
    func addApplePayEnrollmentView() {
        self.addApplePayView.addToView(view)
        self.addApplePayView.setDelegate(self)
    }
    
    func addSuccessAppleEnrollmentView() {
        self.successApplePayEnrollment.addToView(view)
        self.successApplePayEnrollment.setDelegate(self)
    }
    
    func addBottomView() {
        self.view.addSubview(bottomBar)
        self.bottomBar.backButton.isHidden = self.isFirstStep
        self.bottomBar.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.bottomBar.addBackAction(target: self, selector: #selector(didSelectBack))
        self.bottomBar.addNextAction(target: self, selector: #selector(didSelectNext))
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.didSelectNext()
    }
}

extension ApplePayEnrollmentViewController: ApplePayEnrollmentViewProtocol {
    func setViewModel(_ viewModel: PlasticCardViewModel) {
        self.successApplePayEnrollment.setViewModel(viewModel)
    }
    
    func setOfferViewModel(_ viewModel: ApplePayOfferViewModel?) {
        self.addApplePayView.setOfferViewModel(viewModel)
        self.successApplePayEnrollment.setOfferViewModel(viewModel)
    }
    
    func showApplaPaySuccess() {
        self.addApplePayView.removeFromSuperview()
        self.addSuccessAppleEnrollmentView()
        self.view.bringSubviewToFront(self.bottomBar)
    }
    
    func showAddToApplePay() {
        self.successApplePayEnrollment.removeFromSuperview()
        self.addApplePayEnrollmentView()
        self.view.bringSubviewToFront(self.bottomBar)
    }
}

extension ApplePayEnrollmentViewController: CardBoardingStepView {}

extension ApplePayEnrollmentViewController: AddApplePayViewDelegate {
    func didSelectEnrollInApplePay() {
        self.presenter.didSelectEnrollInApplePay()
    }
    
    func didSelectApplePayImage(_ viewModel: ApplePayOfferViewModel) {
        self.presenter.didSelectApplePayOffer(viewModel)
    }
}

extension ApplePayEnrollmentViewController: SuccessAppleEnrollmentViewDelegate {
    func didSelectHowToPay(_ viewModel: ApplePayOfferViewModel) {
        self.presenter.didSelectHowToPay(viewModel)
    }
}

extension ApplePayEnrollmentViewController: ApplePayOperativeViewLauncher {}
