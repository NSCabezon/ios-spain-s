//
//  ProductListConfigurationXibView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 17/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents
import CoreDomain

public enum ProductListConfigurationViewState: State {
    case optionDidChanged(product: ProductConfigurationRepresentable)
    case didTappedMoreOption(bank: ProducListConfigurationOtherBanksRepresentable)
    case didTapReviewCredentials
}

private extension ProductListConfigurationView {}

final class ProductListConfigurationView: XibView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var productsStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var enableAllLabel: UILabel!
    @IBOutlet private weak var enableAllButton: UIButton!
    @IBOutlet private weak var gradientView: UIView!
    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<ProductListConfigurationViewState, Never>()
    public lazy var publisher: AnyPublisher<ProductListConfigurationViewState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var model: ProductListConfigurationRepresentable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    func setupProductList(_ representable: ProductListConfigurationRepresentable) {
        self.model = representable
        configureView()
    }
    
    func updateProducts() {
        updateAllTogglesView()
    }
    
    @IBAction func didTappedEnableAll(_ sender: Any) {
        self.activeAllProducts()
    }
}

private extension ProductListConfigurationView {
    func bind() {}
    
    func setupView() {
        self.titleLabel.font = .typography(fontName: .oneH200Bold)
        self.enableAllLabel.font = .typography(fontName: .oneB300Bold)
        self.enableAllLabel.textColor = .oneDarkTurquoise
        self.enableAllLabel.text = localized("analysis_button_activateAll")
    }
    
    func configureView() {
        guard let model = model else { return }
        self.titleLabel.text = model.type.text
        self.addProducts()
        self.configureEnableAllButton()
        configureBackground()
        setAccessibilityIdentifiers()
    }
    
    func configureEnableAllButton() {
        self.enableAllLabel.isHidden = isAllProductsAvtive()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func addProducts() {
        guard let model = model else { return }
        model.products?.enumerated().forEach { (index, product) in
            let productView = OneProductCardView()
            productView.setupProductCard(product.getProductCardRepresentable(for: model.type))
            productView.setAccessibilitySuffix("_\(model.type.accessibilityIdentifier)\(index + 1)")
            productsStackView.addArrangedSubview(productView)
            let productModel: DefaultProductConfiguration? = product as? DefaultProductConfiguration
            productView.publisher
                .case(OneProductCardState.didChangeToggle)
                .sink { [unowned productModel, self] isOn in
                    guard let productModel = productModel else { return }
                    productModel.setSelected(isOn: isOn)
                    self.configureEnableAllButton()
                    self.subject.send(.optionDidChanged(product: productModel))
                }.store(in: &subscriptions)
        }
        model.otherBanksInfo?.enumerated().forEach { (index, product) in
            let bankView = OneProductCardView()
            bankView.setupProductCard(product.getProductCardRepresentable())
            bankView.setAccessibilitySuffix("_\(model.type.accessibilityIdentifier)\(index + 1)")
            productsStackView.addArrangedSubview(bankView)
            let bankModel = product as? DefaultProducListConfigurationOtherBanks
            bankView.publisher
                .case(OneProductCardState.didTappedMoreActionButton)
                .sink { [unowned bankModel, self] _ in
                    guard let bankModel = bankModel else { return }
                    self.subject.send(.didTappedMoreOption(bank: bankModel))
                }.store(in: &subscriptions)
            bankView.publisher
                .case(OneProductCardState.didTappedNotificationLink)
                .sink { [unowned bankModel, self] _ in
                    guard let bankModel = bankModel else { return }
                    self.subject.send(.didTapReviewCredentials)
                }.store(in: &subscriptions)
        }
    }
    
    func configureBackground() {
        guard let model = model else { return }
        if model.type == .otherBanks {
            self.gradientView.applyOneGradient(.oneGrayGradient(direction: .topToBottom))
        }
    }
    
    func isAllProductsAvtive() -> Bool {
        guard let model = model else { return true }
        if model.type == .otherBanks { return true }
        let productUnselected = model.products?.filter { $0.selected == false }.count ?? 0
        return productUnselected == 0
    }
    
    func activeAllProducts() {
        guard let model = model else { return }
        model.products?.filter { $0.selected == false }.forEach {
            $0.setSelected(isOn: true)
            self.subject.send(.optionDidChanged(product: $0))
        }
        productsStackView.subviews.compactMap { $0 as? OneProductCardView }.forEach { $0.setToggleView(true) }
        configureEnableAllButton()
    }
    
    func updateAllTogglesView() {
        guard let model = model else { return }
        productsStackView.subviews.compactMap { $0 as? OneProductCardView }.enumerated().forEach { index, product in
            if let productModel = model.products?[index], let isSelected = productModel.selected {
                product.setToggleView(isSelected)
            }
        }
    }
    
    func setAccessibilityInfo() {
        titleLabel.accessibilityLabel = "\(model?.products?.count ?? 0). \(titleLabel.text ?? "")"
        enableAllLabel.accessibilityLabel = enableAllLabel.text
        enableAllLabel.accessibilityTraits = .button
        enableAllLabel.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(didTapActivateAll)))
        enableAllButton.isAccessibilityElement = false
    }
    
    func setAccessibilityIdentifiers() {
        guard let model = model else { return }
        self.titleLabel.accessibilityIdentifier = model.type.accessibilityIdentifier
        self.enableAllButton.accessibilityIdentifier = "\(AnalysisAreaAccessibility.btnAnalysisActivateAll)_\(model.type.accessibilityIdentifier)"
        self.enableAllLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.labelAnalysisActivateAll)_\(model.type.accessibilityIdentifier)"
    }
    
    @objc func didTapActivateAll() {
        self.activeAllProducts()
    }
}

extension ProductListConfigurationView: AccessibilityCapable {}
