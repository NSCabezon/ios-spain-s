//
//  EasyPayConfigurationViewController.swift
//  Cards
//
//  Created by alvola on 02/12/2020.
//

import UIKit
import Operative
import UI
import CoreFoundationLib

protocol EasyPayConfigurationViewProtocol: OperativeView {
    func setCurrentFees(_ current: Int)
    func setOperativeDescription(_ description: LocalizedStylableText)
    func setMovementInfo(_ info: EasyPayHeaderMovementViewModel)
    func setMonthlyFees(_ fees: [[MonthlyFeeViewModel]])
    func setFirstFeeInfo(viewModel: CurrentFeeDetailViewModel)
    func showContinue(_ show: Bool)
    func showMonthlyFees(_ show: Bool)
    func showCurrentFee(_ show: Bool)
    func showPaymentPlan(_ show: Bool)
    func showSlideToActive(_ show: Bool)
    func showLoading(_ show: Bool)
    func showError(_ description: String?)
    func showSimpleError(_ isHidden: Bool) 
}

final class EasyPayConfigurationViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var continueArea: UIView!
    @IBOutlet private var continueButton: WhiteLisboaButton!
    @IBOutlet private var continueButtonHeight: NSLayoutConstraint!
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.containerView)
        view.setScrollInsets(UIEdgeInsets(top: -13, left: 0.0, bottom: 0.0, right: 0.0))
        return view
    }()
    
    private var headerViewContainer: UIView? {
        return headerView.superview
    }
    
    private lazy var headerView: EasyPayHeaderMovementView = {
        let view = EasyPayHeaderMovementView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "detailListMovement"
        return view
    }()
    
    private var descriptionViewContainer: UIView? {
        return descriptionView.superview
    }
    
    private lazy var descriptionView: EasyPayDescriptionView = {
        let view = EasyPayDescriptionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var feeSelectorViewContainer: UIView? {
        return feeSelectorView.superview
    }
    
    private lazy var feeSelectorView: EasyPayFeeSelectorView = {
        let view = EasyPayFeeSelectorView(max: presenter?.maxFees ?? 36,
                                          min: presenter?.minFees ?? 2,
                                          delay: presenter?.pressDelay ?? 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "easyPayBtnSelectQuota"
        view.delegate = self
        return view
    }()
    
    private var currentFeeDetailViewContainer: UIView? {
        return currentFeeDetailView.superview
    }
    
    private lazy var currentFeeDetailView: CurrentFeeDetailView = {
        return CurrentFeeDetailView()
    }()
    
    private var paymentPlanViewContainer: UIView? {
        return paymentPlanView.superview
    }
    
    private lazy var paymentPlanView: EasyPayPaymentPlanView = {
        let view = EasyPayPaymentPlanView(frame: .zero, type: .easyPay)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var simpleErrorContainer: UIView? {
        return simpleError.superview
    }
    
    private lazy var simpleError: EasyPaySimpleError = {
        let view = EasyPaySimpleError(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var loadingViewContainer: UIView? {
        return loadingView.superview
    }
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 240.0).isActive = true
        view.backgroundColor = .clear
        let type = LoadingViewType.onView(view: view,
                                          frame: nil,
                                          position: .top,
                                          controller: self)
        let text = LoadingText(title: localized("easyPay_loader_calculated"),
                               subtitle: localized("loading_label_moment"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               background: .clear,
                               loadingImageType: .points,
                               style: .onView)
        LoadingCreator.createAndShowLoading(info: info)
        return view
    }()
    
    private var slideToActionViewContainer: UIView? {
        return slideToActionView.superview
    }
    
    private lazy var slideToActionView: UIView = {
        let slider = SlideToActionView(frontText: localized("easyPay_button_swipeToConfirm"),
                                       backText: localized("easyPay_button_swipeToConfirm"),
                                       image: Assets.image(named: "slideToActionIcon"),
                                       style: .easyPay,
                                       delegate: self)
        slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let view = slider.embedIntoView(topMargin: 16.0,
                                        bottomMargin: 16.0,
                                        leftMargin: 16.0,
                                        rightMargin: 16.0)
        view.backgroundColor = .white
        return view
    }()
    
    var operativePresenter: OperativeStepPresenterProtocol
    
    var presenter: EasyPayConfigurationPresenterProtocol? {
        operativePresenter as? EasyPayConfigurationPresenterProtocol
    }
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: EasyPayConfigurationPresenterProtocol) {
        self.operativePresenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

private extension EasyPayConfigurationViewController {
    func commonInit() {
        configureView()
        configureButton()
    }
    
    func configureView() {
        self.view.backgroundColor = .skyGray
        self.containerView.backgroundColor = .clear
        scrollableStackView.addArrangedSubview(headerView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(descriptionView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(feeSelectorView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(currentFeeDetailView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(loadingView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(simpleError.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(paymentPlanView.embedIntoView(leftMargin: 16.0, rightMargin: 16.0))
        scrollableStackView.addArrangedSubview(slideToActionView)
    }
    
    func configureButton() {
        continueButton.addSelectorAction(target: self, #selector(continuePressed))
        continueButton.setTitle(localized("generic_button_continue"),
                                for: UIControl.State.normal)
        continueButton.accessibilityIdentifier = "generic_button_continue"
        continueArea.addShadow(location: .top,
                               color: .atmsShadowGray,
                               opacity: 1.0,
                               radius: 4.0,
                               height: 2.0)
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(style: .white,
                                           title: .title(key: "toolbar_title_easyPay"))
        builder.setRightActions(NavigationBarBuilder.RightAction.close(action: #selector(close)))
        builder.build(on: self, with: nil)
    }
    
    @objc func close() {
        presenter?.close()
    }
    
    @objc func continuePressed() {
        presenter?.continuePressed()
    }
}

extension EasyPayConfigurationViewController: EasyPayConfigurationViewProtocol {
    var progressBarBackgroundColor: UIColor {
        .white
    }
    
    func showPaymentPlan(_ show: Bool) {
        paymentPlanViewContainer?.isHidden = show
    }
    
    func showLoading(_ show: Bool) {
        loadingViewContainer?.isHidden = !show
    }
    
    func showCurrentFee(_ show: Bool) {
        currentFeeDetailViewContainer?.isHidden = !show
    }
    
    func showMonthlyFees(_ show: Bool) {
        paymentPlanViewContainer?.isHidden = !show
    }
    
    func showSlideToActive(_ show: Bool) {
        slideToActionView.isHidden = !show
    }
    
    func showContinue(_ show: Bool) {
        continueButtonHeight.constant = show ? 70.0 : 0.0
        continueArea.isHidden = !show
    }
    
    func showError(_ description: String?) {
        simpleError.setErrorDescription(description)
        showSimpleError(false)
    }
    
    func showSimpleError(_ isHidden: Bool) {
        simpleErrorContainer?.isHidden = isHidden
    }
    
    func setCurrentFees(_ current: Int) {
        feeSelectorView.setCurrent(current)
    }
    
    func setMovementInfo(_ info: EasyPayHeaderMovementViewModel) {
        headerView.setInfo(info)
    }
    
    func setMonthlyFees(_ fees: [[MonthlyFeeViewModel]]) {
        paymentPlanView.setMonthlyFees(fees)
    }
    
    func setOperativeDescription(_ description: LocalizedStylableText) {
        descriptionView.setDescription(description)
    }
        
    func setFirstFeeInfo(viewModel: CurrentFeeDetailViewModel) {
        currentFeeDetailView.setViewInfo(with: viewModel)
    }
}

extension EasyPayConfigurationViewController: EasyPayFeeSelectorViewDelegate {
    func didSelectFeeNumber(_ fee: Int) {
        presenter?.setCurrentFees(fee)
    }
    
    func didTrackFeeNumber() {
        presenter?.setTrackChangedFees()
    }
}

extension EasyPayConfigurationViewController: SlideToActionDelegateProtocol {
    func slideToActionDidFinish(_ sender: SlideToActionView) {
        presenter?.slideToConfirmCompleted()
        sender.resetStateWithAnimation(true)
    }
}
