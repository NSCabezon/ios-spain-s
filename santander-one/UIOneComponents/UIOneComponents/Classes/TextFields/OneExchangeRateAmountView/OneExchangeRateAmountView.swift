//
//  OneExchangeRateAmountView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 20/4/22.
//

import OpenCombine
import CoreFoundationLib
import CoreDomain
import UIKit
import UI

public protocol ReactiveOneExchangeRateAmountView {
    var publisher: AnyPublisher<OneExchangeRateAmountViewState, Never> { get }
}

public enum OneExchangeRateAmountViewState: State {
    case didChangeOriginAmount(_ originAmount: AmountRepresentable, _ newDestinationAmount: AmountRepresentable)
    case didEndEditingOriginAmount(_ originAmount: AmountRepresentable, _ newDestinationAmount: AmountRepresentable)
    case didChangeDestinationAmount(_ newOriginAmount: AmountRepresentable, _ destinationAmount: AmountRepresentable)
    case didEndEditingDestinationAmount(_ newOriginAmount: AmountRepresentable, _ destinationAmount: AmountRepresentable)
}

public final class OneExchangeRateAmountView: UIView {
    private lazy var mainStackView: UIStackView = {
        return getVerticalStackView()
    }()
    private lazy var originAmountTitleLabel: OneLabelView = {
        return getOneLabelView(key: Constants.Origin.amountTitleKey)
    }()
    private lazy var originAmountView: OneInputAmountView = {
        return getOneInputAmountView(with: viewModel?.originAmount)
    }()
    private lazy var originSelectCurrencyTitleLabel: OneLabelView = {
        return getOneLabelView(key: Constants.Currency.titleKey)
    }()
    private lazy var originSelectCurrencyView: OneInputSelectView = {
        return getOneInputSelectView(with: viewModel?.originAmount)
    }()
    private lazy var originAmountAndCurrencyView: UIStackView = {
        return getAmountAndCurrencyView(amountTitleLabel: originAmountTitleLabel,
                                        amountView: originAmountView,
                                        selectCurrencyTitleLabel: originSelectCurrencyTitleLabel,
                                        selectCurrencyView: originSelectCurrencyView)
    }()
    public lazy var listFlowStackView: UIStackView = {
        return getVerticalStackView()
    }()
    private lazy var amountListFlowItemViewModel: OneListFlowItemViewModel = {
        guard viewModel?.originAmount.currencySelector == nil else {
            return OneListFlowItemViewModel(items: [OneListFlowItemViewModel.Item(type: .custom(view: originAmountAndCurrencyView))])
        }
        return OneListFlowItemViewModel(items: [OneListFlowItemViewModel.Item(type: .custom(view: originAmountTitleLabel)),
                                                OneListFlowItemViewModel.Item(type: .spacing(height: Constants.OneListFlowItem.Constraints.spacingBetweenLabelAndInput)),
                                                OneListFlowItemViewModel.Item(type: .custom(view: originAmountView))])
    }()
    private lazy var buyRateLabel: UILabel = {
        return getRateLabel()
    }()
    private lazy var buyRateListFlowItemViewModel: OneListFlowItemViewModel = {
        return OneListFlowItemViewModel(items: [OneListFlowItemViewModel.Item(type: .title(keyOrValue: Constants.BuyRate.titleKey)),
                                                OneListFlowItemViewModel.Item(type: .custom(view: buyRateLabel))])
    }()
    private lazy var sellRateLabel: UILabel = {
        return getRateLabel()
    }()
    private lazy var sellRateListFlowItemViewModel: OneListFlowItemViewModel = {
        return OneListFlowItemViewModel(items: [OneListFlowItemViewModel.Item(type: .title(keyOrValue: Constants.SellRate.titleKey)),
                                                OneListFlowItemViewModel.Item(type: .custom(view: sellRateLabel))])
    }()
    private lazy var receiveAmountTitleLabel: OneLabelView = {
        return getOneLabelView(key: Constants.Destination.amountTitleKey)
    }()
    private lazy var receiveAmountView: OneInputAmountView = {
        guard case .exchange(let destinationAmount) = viewModel?.type else { return OneInputAmountView() }
        return getOneInputAmountView(with: destinationAmount)
    }()
    private lazy var receiveSelectCurrencyTitleLabel: OneLabelView = {
        return getOneLabelView(key: Constants.Currency.titleKey)
    }()
    private lazy var receiveSelectCurrencyView: OneInputSelectView = {
        guard case .exchange(let destinationAmount) = viewModel?.type else { return OneInputSelectView() }
        return getOneInputSelectView(with: destinationAmount)
    }()
    private lazy var receiveAmountAndCurrencyView: UIStackView = {
        return getAmountAndCurrencyView(amountTitleLabel: receiveAmountTitleLabel,
                                        amountView: receiveAmountView,
                                        selectCurrencyTitleLabel: receiveSelectCurrencyTitleLabel,
                                        selectCurrencyView: receiveSelectCurrencyView)
    }()
    private lazy var receiveAmountListFlowItemViewModel: OneListFlowItemViewModel = {
        guard case .exchange(let destinationAmount) = viewModel?.type else { return OneListFlowItemViewModel() }
        guard destinationAmount.currencySelector == nil else {
            return OneListFlowItemViewModel(isLastItem: true,
                                            items: [OneListFlowItemViewModel.Item(type: .custom(view: receiveAmountAndCurrencyView))])
        }
        return OneListFlowItemViewModel(isLastItem: true,
                                        items: [OneListFlowItemViewModel.Item(type: .custom(view: receiveAmountTitleLabel)),
                                                OneListFlowItemViewModel.Item(type: .spacing(height: Constants.OneListFlowItem.Constraints.spacingBetweenLabelAndInput)),
                                                OneListFlowItemViewModel.Item(type: .custom(view: receiveAmountView))])
    }()
    private lazy var alertView: OneAlertView = {
        let alertView = OneAlertView(frame: .zero)
        return alertView
    }()
    private var viewModel: OneExchangeRateAmountViewModel?
    private let stateSubject = PassthroughSubject<OneExchangeRateAmountViewState, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private var accessibilityTitleLabelsSuffix: Int = 1
    private var accessibilityRateLabelsSuffix: Int = 1
    
    public init(viewModel: OneExchangeRateAmountViewModel) {
        super.init(frame: .zero)
        setupView()
        setViewModel(viewModel)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OneExchangeRateAmountViewModel) {
        self.viewModel = viewModel
        configureView()
        bind()
        setAccessibilityIdentifiers(suffix: viewModel.accessibilitySuffix)
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        setAccessibilityIdentifiers(suffix: suffix)
    }
    
    public func getOriginAmount() -> String {
        return originAmountView.getAmount()
    }
    
    public func setOriginAmount(_ amount: String) {
        originAmountView.setAmount(amount)
    }
    
    public func getDestinationAmount() -> String {
        return receiveAmountView.getAmount()
    }
    
    public func setDestinationAmount(_ amount: String) {
        receiveAmountView.setAmount(amount)
    }
    
    public func isOriginAmountFirstResponder() -> Bool {
        return originAmountView.isTextFieldFirstResponder()
    }
    
    public func isDestinationAmountFirstResponder() -> Bool {
        return receiveAmountView.isTextFieldFirstResponder()
    }
}

// MARK: - View
private extension OneExchangeRateAmountView {
    enum Constants {
        enum AmountInput {
            static let placeholder: String = "0,00"
            enum Constraints {
                static let spaceBetweenCurrency: CGFloat = 15.0
            }
        }
        enum SelectView {
            enum Constraints {
                static let height: CGFloat = 48.0
                static let width: CGFloat = 95.0
            }
        }
        enum OneListFlowItem {
            enum Constraints {
                static let spacingBetweenLabelAndInput: CGFloat = .zero
            }
        }
        enum Origin {
            static let amountTitleKey: String = "sendMoney_label_amount"
            enum Constraints {
                static let spacing: CGFloat = 8.0
            }
        }
        enum Currency {
            static let titleKey: String = "sendMoney_label_currency"
        }
        enum BuyRate {
            static let titleKey: String = "sendMoney_label_exchangeBuyRate"
        }
        enum SellRate {
            static let titleKey: String = "sendMoney_label_exchangeSellRate"
        }
        enum Destination {
            static let amountTitleKey: String = "sendMoney_label_recipientWillReceive"
        }
    }
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        mainStackView.fullFit()
    }
    
    func configureView() {
        guard let viewModel = viewModel else { return }
        clearView()
        switch viewModel.type {
        case .noExchange:
            configureViewForSameCurrency()
        case .exchange:
            configureViewForDifferentCurrencies(with: viewModel.type)
        }
        configureAlert(viewModel.alert)
    }
    
    func clearView() {
        listFlowStackView.removeAllArrangedSubviews()
        mainStackView.removeAllArrangedSubviews()
    }
    
    func configureViewForSameCurrency() {
        mainStackView.addArrangedSubview(originAmountTitleLabel)
        mainStackView.addArrangedSubview(originAmountView)
        if #available(iOS 11.0, *) {
            mainStackView.setCustomSpacing(Constants.Origin.Constraints.spacing, after: originAmountTitleLabel)
        }
    }
    
    func configureViewForDifferentCurrencies(with type: OneExchangeRateAmountViewType) {
        fillListFlowStackView(with: getOneListFlowItemViewModels(for: type))
        mainStackView.addArrangedSubview(listFlowStackView)
        setConstraints()
    }
    
    func setConstraints() {
        guard let viewModel = viewModel else { return }
        if viewModel.originAmount.currencySelector == nil {
            originAmountView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        } else {
            originAmountAndCurrencyView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        }
        guard case .exchange(let destinationAmount) = viewModel.type else { return }
        if destinationAmount.currencySelector == nil {
            receiveAmountView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        } else {
            receiveAmountAndCurrencyView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor).isActive = true
        }
    }

    func getOneListFlowItemViewModels(for type: OneExchangeRateAmountViewType) -> [OneListFlowItemViewModel] {
        guard let viewModel = viewModel,
              case .exchange(let destinationAmount) = viewModel.type else { return [] }
        var items: [OneListFlowItemViewModel] = []
        items.append(amountListFlowItemViewModel)
        configureBuyRate(amount: isDoubleExchange() ? destinationAmount : viewModel.originAmount, listFlowItems: &items)
        configureSellRate(amount: isDoubleExchange() ? viewModel.originAmount : destinationAmount, listFlowItems: &items)
        items.append(receiveAmountListFlowItemViewModel)
        return items
    }
    
    func configureBuyRate(amount: OneExchangeRateAmount, listFlowItems: inout [OneListFlowItemViewModel]) {
        guard !amount.hasSameAmountAndRatesCurrencies() else { return }
        buyRateLabel.text = getRateString(amount: amount.amount, rate: amount.buyRate)
        listFlowItems.append(buyRateListFlowItemViewModel)
    }
    
    func configureSellRate(amount: OneExchangeRateAmount, listFlowItems: inout [OneListFlowItemViewModel]) {
        guard !amount.hasSameAmountAndRatesCurrencies() else { return }
        sellRateLabel.text = getRateString(amount: amount.amount, rate: amount.sellRate)
        listFlowItems.append(sellRateListFlowItemViewModel)
    }
    
    func isDoubleExchange() -> Bool {
        guard let viewModel = viewModel,
              case .exchange(let destinationAmount) = viewModel.type else { return false }
        return !viewModel.originAmount.hasSameAmountAndRatesCurrencies() && !destinationAmount.hasSameAmountAndRatesCurrencies()
    }
    
    func getRateString(amount: AmountRepresentable, rate: AmountRepresentable) -> String {
        let decorator = AmountRepresentableDecorator(rate, font: .typography(fontName: .oneB400Bold))
        return "1 \(amount.currencyRepresentable?.currencyCode ?? "") = \(decorator.getFormatedWithCurrencyName()?.string ?? "")"
    }
    
    func fillListFlowStackView(with viewModels: [OneListFlowItemViewModel]) {
        var indexPath = IndexPath(item: .zero, section: .zero)
        viewModels.forEach {
            let listFlowItem = OneListFlowItemView()
            listFlowItem.setupViewModel($0, at: indexPath)
            indexPath.row += 1
            listFlowStackView.addArrangedSubview(listFlowItem)
        }
    }
    
    func configureAlert(_ alert: OneExchangeRateAmountAlert?) {
        guard let alert = alert else { return }
        alertView.setType(.textAndImage(imageKey: alert.iconName,
                                        stringKey: localized(alert.titleKey)))
        mainStackView.addArrangedSubview(alertView)
    }
    
    func getVerticalStackView() -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        return verticalStackView
    }
    
    func getHorizontalStackView() -> UIStackView {
        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .horizontal
        return verticalStackView
    }
    
    func getOneLabelView(key: String) -> OneLabelView {
        let amountLabelViewModel = OneLabelViewModel(type: .normal,
                                                     mainTextKey: key,
                                                     accessibilitySuffix: AccessibilityOneComponents.oneExchangeRateAmountTitle + "\(accessibilityTitleLabelsSuffix)")
        accessibilityTitleLabelsSuffix += 1
        let amountTitleLabel = OneLabelView()
        amountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        amountTitleLabel.setupViewModel(amountLabelViewModel)
        return amountTitleLabel
    }
    
    func getOneInputAmountView(with amount: OneExchangeRateAmount?) -> OneInputAmountView {
        guard let amount = amount else { return OneInputAmountView() }
        let oneInputAmountView = OneInputAmountView()
        oneInputAmountView.setupTextField(OneInputAmountViewModel(status: .activated,
                                                                  type: amount.currencySelector == nil ? .text : .unowned,
                                                                  placeholder: Constants.AmountInput.placeholder,
                                                                  amountRepresentable: amount.currencySelector == nil ? amount.amount : nil))
        oneInputAmountView.setAmount(amount.amount.value?.formattedRoundingDown ?? "")
        return oneInputAmountView
    }
    
    func getOneInputSelectView(with amount: OneExchangeRateAmount?) -> OneInputSelectView {
        guard let amount = amount,
              let currencySelector = amount.currencySelector else { return OneInputSelectView() }
        let selectView = OneInputSelectView()
        selectView.setViewModel(OneInputSelectViewModel(type: .bottomSheet(view: currencySelector, type: .top),
                                                        status: .activated,
                                                        pickerData: [amount.amount.currencyRepresentable?.currencyCode ?? ""],
                                                        selectedInput: .zero))
        selectView.heightAnchor.constraint(equalToConstant: Constants.SelectView.Constraints.height).isActive = true
        selectView.widthAnchor.constraint(equalToConstant: Constants.SelectView.Constraints.width).isActive = true
        return selectView
    }
    
    func getAmountAndCurrencyView(amountTitleLabel: OneLabelView, amountView: OneInputAmountView, selectCurrencyTitleLabel: OneLabelView, selectCurrencyView: OneInputSelectView) -> UIStackView {
        let horizontalStackView = getHorizontalStackView()
        horizontalStackView.spacing = Constants.AmountInput.Constraints.spaceBetweenCurrency
        let amountStackView = getVerticalStackView()
        amountStackView.spacing = Constants.Origin.Constraints.spacing
        amountStackView.addArrangedSubview(amountTitleLabel)
        amountStackView.addArrangedSubview(amountView)
        let currencyStackView = getVerticalStackView()
        currencyStackView.spacing = Constants.Origin.Constraints.spacing
        currencyStackView.addArrangedSubview(selectCurrencyTitleLabel)
        currencyStackView.addArrangedSubview(selectCurrencyView)
        horizontalStackView.addArrangedSubview(amountStackView)
        horizontalStackView.addArrangedSubview(currencyStackView)
        return horizontalStackView
    }
    
    func getRateLabel() -> UILabel {
        let rateLabel = UILabel()
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.numberOfLines = .zero
        rateLabel.font = .typography(fontName: .oneB400Bold)
        rateLabel.textColor = .oneLisboaGray
        rateLabel.accessibilityIdentifier = AccessibilityOneComponents.oneExchangeRateAmountText + "\(accessibilityRateLabelsSuffix)"
        accessibilityRateLabelsSuffix += 1
        return rateLabel
    }
    
    func setAccessibilityIdentifiers(suffix: String = "") {
        accessibilityIdentifier = AccessibilityOneComponents.oneExchangeRateAmountView + suffix
        originAmountTitleLabel.accessibilityIdentifier = originAmountTitleLabel.accessibilityIdentifier ?? "" + suffix
        originSelectCurrencyTitleLabel.accessibilityIdentifier = originSelectCurrencyTitleLabel.accessibilityIdentifier ?? "" + suffix
        receiveAmountTitleLabel.accessibilityIdentifier = receiveAmountTitleLabel.accessibilityIdentifier ?? "" + suffix
        receiveSelectCurrencyTitleLabel.accessibilityIdentifier = receiveSelectCurrencyTitleLabel.accessibilityIdentifier ?? "" + suffix
        buyRateLabel.accessibilityIdentifier = buyRateLabel.accessibilityIdentifier ?? "" + suffix
        sellRateLabel.accessibilityIdentifier = sellRateLabel.accessibilityIdentifier ?? "" + suffix
    }
}

// MARK: - Logic
private extension OneExchangeRateAmountView {
    func calculateAmount(amount: Decimal, isDestinationEdited: Bool) -> Decimal {
        guard let originAmount = viewModel?.originAmount,
              case .exchange(let destinationAmount) = viewModel?.type,
              let originAmountBuyRate = originAmount.buyRate.value,
              let originAmountSellRate = originAmount.sellRate.value,
              let destinationAmountBuyRate = destinationAmount.buyRate.value,
              let destinationAmountSellRate = destinationAmount.sellRate.value else { return .zero }
        var newAmount = amount
        if originAmount.hasSameAmountAndRatesCurrencies() {
            newAmount = newAmount * (isDestinationEdited ? destinationAmountSellRate : (1 / destinationAmountSellRate))
        } else if !destinationAmount.hasSameAmountAndRatesCurrencies() {
            newAmount = newAmount * (isDestinationEdited ? (1 / originAmountSellRate) : originAmountSellRate)
        }
        if destinationAmount.hasSameAmountAndRatesCurrencies() {
            newAmount = newAmount * (isDestinationEdited ? (1 / originAmountBuyRate) : originAmountBuyRate)
        } else if !originAmount.hasSameAmountAndRatesCurrencies() {
            newAmount = newAmount * (isDestinationEdited ? destinationAmountBuyRate : (1 / destinationAmountBuyRate))
        }
        return newAmount
    }
    
    func storeAmounts(oldAmount: Decimal, newAmount: Decimal, isDestinationEdited: Bool = false) {
        guard let originCurrency = viewModel?.originAmount.amount.currencyRepresentable,
              case .exchange(var destinationAmount) = viewModel?.type,
              let destinationCurrency = destinationAmount.amount.currencyRepresentable else {
                  return
              }
        viewModel?.originAmount.amount = AmountRepresented(value: isDestinationEdited ? newAmount : oldAmount, currencyRepresentable: originCurrency)
        viewModel?.type.setDestinationAmount(AmountRepresented(value: isDestinationEdited ? oldAmount : newAmount, currencyRepresentable: destinationCurrency))
        if isDestinationEdited {
            originAmountView.setAmount(newAmount.formattedRoundingDown)
        } else {
            receiveAmountView.setAmount(newAmount.formattedRoundingDown)
        }
    }
}

// MARK: - Binds
private extension OneExchangeRateAmountView {
    func bind() {
        bindOriginAmountDidChange()
        bindOriginAmountDidEndEditing()
        bindReceiveAmountDidChange()
        bindReceiveAmountDidEndEditing()
    }
    
    func bindOriginAmountDidChange() {
        originAmountView.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidChange)
            .sink { [unowned self] _ in
                if let originAmountValue = originAmountView.getAmount().stringToDecimal {
                    let newAmount = calculateAmount(amount: originAmountValue, isDestinationEdited: false)
                    storeAmounts(oldAmount: originAmountValue, newAmount: newAmount)
                } else {
                    storeAmounts(oldAmount: .zero, newAmount: .zero)
                }
                guard let originAmount = viewModel?.originAmount,
                      case .exchange(let destinationAmount) = viewModel?.type else { return }
                stateSubject.send(.didChangeOriginAmount(originAmount.amount, destinationAmount.amount))
            }.store(in: &subscriptions)
    }
    
    func bindOriginAmountDidEndEditing() {
        originAmountView.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidEndEditing)
            .sink { [unowned self] _ in
                guard let originAmount = viewModel?.originAmount,
                      case .exchange(let destinationAmount) = viewModel?.type else { return }
                stateSubject.send(.didEndEditingOriginAmount(originAmount.amount, destinationAmount.amount))
            }.store(in: &subscriptions)
    }
    
    func bindReceiveAmountDidChange() {
        receiveAmountView.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidChange)
            .sink { [unowned self] _ in
                if let receiveAmount = receiveAmountView.getAmount().stringToDecimal {
                    let newAmount = calculateAmount(amount: receiveAmount, isDestinationEdited: true)
                    storeAmounts(oldAmount: receiveAmount, newAmount: newAmount, isDestinationEdited: true)
                } else {
                    storeAmounts(oldAmount: .zero, newAmount: .zero, isDestinationEdited: true)
                }
                guard let originAmount = viewModel?.originAmount,
                      case .exchange(let destinationAmount) = viewModel?.type else { return }
                stateSubject.send(.didChangeDestinationAmount(originAmount.amount, destinationAmount.amount))
            }.store(in: &subscriptions)
    }
    
    func bindReceiveAmountDidEndEditing() {
        receiveAmountView.publisher
            .case(ReactiveOneInputAmountViewState.textFieldDidEndEditing)
            .sink { [unowned self] _ in
                guard let originAmount = viewModel?.originAmount,
                      case .exchange(let destinationAmount) = viewModel?.type else { return }
                stateSubject.send(.didEndEditingDestinationAmount(originAmount.amount, destinationAmount.amount))
            }.store(in: &subscriptions)
    }
}

extension OneExchangeRateAmountView: ReactiveOneExchangeRateAmountView {
    public var publisher: AnyPublisher<OneExchangeRateAmountViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

fileprivate extension Decimal {
    var formattedRoundingDown: String {
        return self.isZero ? "" : self.rounded(roundingMode: .down).getLocalizedStringValue()
    }
}
