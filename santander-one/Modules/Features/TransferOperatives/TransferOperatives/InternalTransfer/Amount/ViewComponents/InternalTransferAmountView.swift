//
//  InternalTransferAmountView.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 24/2/22.
//

import UIOneComponents
import CoreFoundationLib
import UIKit
import OpenCombine
import CoreDomain

public protocol ReactiveInternalTransferAmountView {
    var publisher: AnyPublisher<InternalTransferAmountViewState, Never> { get }
}
public enum InternalTransferAmountViewState: State {
    case didChangeAmount(_ amount: String)
    case didEndEditingAmount
    case didChangeWillReceive(_ amount: String)
    case didEndEditingWillReceive
}

enum InternalTransferAmountViewType {
    case noExchange
    case simpleExchange(String)
    case doubleExchange(String, String)
}

final class InternalTransferAmountView: UIView {
    private enum Constants {
        static let emptyAmountPlaceholder = "0,00"
    }

    private let originCurrency: CurrencyRepresentable
    private let destinationCurrency: CurrencyRepresentable
    private lazy var amountAndDateLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = .zero
        titleLabel.font = .typography(fontName: .oneH100Bold)
        titleLabel.textColor = .oneLisboaGray
        titleLabel.configureText(withKey: "sendMoney_label_amoundDate")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    private lazy var amountView: OneInputAmountView = {
        let view = OneInputAmountView()
        view.setupTextField(OneInputAmountViewModel(status: .activated,
                                                    type: .text,
                                                    placeholder: Constants.emptyAmountPlaceholder,
                                                    amountRepresentable: AmountRepresented(value: 0, currencyRepresentable:originCurrency)))
        return view

    }()
    private lazy var receiveAmountView: OneInputAmountView = {
        let view = OneInputAmountView()
        view.setupTextField(OneInputAmountViewModel(status: .activated,
                                                    type: .text,
                                                    placeholder: Constants.emptyAmountPlaceholder,
                                                    amountRepresentable: AmountRepresented(value: 0, currencyRepresentable:destinationCurrency)))
        return view
    }()
    private var subscriptions: Set<AnyCancellable> = []
    private let stateSubject = PassthroughSubject<InternalTransferAmountViewState, Never>()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    private lazy var alertView: OneAlertView = {
        let alertView = OneAlertView(frame: .zero)
        alertView.setType(.textAndImage(imageKey: "icnInfoGray", stringKey: localized("sendMoney_label_conversionExchangeRate")))
        return alertView
    }()

    private lazy var sellRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .typography(fontName: .oneB400Bold)
        label.textColor = .oneLisboaGray
        return label
    }()

    private lazy var buyRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .typography(fontName: .oneB400Bold)
        label.textColor = .oneLisboaGray
        return label
    }()

    public init (originCurrency: CurrencyRepresentable, destinationCurrency: CurrencyRepresentable) {
        self.originCurrency = originCurrency
        self.destinationCurrency = destinationCurrency
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configureView()
        bindAmountDidChange()
        bindAmountDidEndEditing()
        bindWillReceiveDidChange()
        bindWillReceiveDidEndEditing()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func getAmount() -> String {
        return amountView.getAmount()
    }

    public func setAmount(_ amount: String?){
        guard let amount = amount else { return }
        amountView.setAmount(amount)
    }

    public func getReceiveAmount() -> String {
        return receiveAmountView.getAmount()
    }

    public func setReceiveAmount(_ amount: String?){
        guard let amount = amount else { return }
        receiveAmountView.setAmount(amount)
    }

    public func updateRatesInformation(buyRate: String?, sellRate: String?) {
        if let sellRate = sellRate {
            sellRateLabel.text = sellRate
        }
        if let buyRate = buyRate {
            buyRateLabel.text = buyRate
        }
    }

    public func isAmountFirstResponder() -> Bool {
        return amountView.isTextFieldFirstResponder()
    }

    public func isReceiveAmountFirstResponder() -> Bool {
        return receiveAmountView.isTextFieldFirstResponder()
    }

    public func configureView(for viewType: InternalTransferAmountViewType) {
        switch viewType {
        case .noExchange:
            configureViewForSameCurrency()
        case .simpleExchange(let sellExchange):
            configureViewForDifferentCurrencies(with: .simpleExchange(sellExchange))
        case .doubleExchange(let sellExchange, let buyExchange):
            configureViewForDifferentCurrencies(with: .doubleExchange(sellExchange, buyExchange))
        }
    }
}

private extension InternalTransferAmountView {

    func configureView() {
        addSubviews()
        setAccessibilityIdentifiers()
    }

    func addSubviews() {
        addSubview(stackView)
        stackView.fullFit()
    }

    func configureViewForSameCurrency() {
        let oneLabelViewModel = OneLabelViewModel(type: .normal, mainTextKey: "sendMoney_label_amount")
        let amountLabel = OneLabelView()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.setAccessibilitySuffix(AccessibilitySendMoneyAmount.amountSuffix)
        amountLabel.setupViewModel(oneLabelViewModel)
        stackView.addArrangedSubview(amountLabel)
        stackView.addArrangedSubview(amountView)
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(8, after: amountLabel)
        }
    }

    func configureViewForDifferentCurrencies(with type: InternalTransferAmountViewType) {
        let viewModels = oneListFlowItemViewModels(for: type)
        let listStackView = listFlowItemViewStackView(with: viewModels)
        stackView.addArrangedSubview(amountAndDateLabel)
        stackView.addArrangedSubview(listStackView)
        stackView.addArrangedSubview(alertView)
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(24.0, after: amountAndDateLabel)
        }
        NSLayoutConstraint.activate([
            amountView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            receiveAmountView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            sellRateLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            sellRateLabel.heightAnchor.constraint(equalToConstant: 24.0),
        ])
        if case .doubleExchange(_, _) = type {
            NSLayoutConstraint.activate([
                buyRateLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
                buyRateLabel.heightAnchor.constraint(equalToConstant: 24.0)
            ])
        }
    }

    func oneListFlowItemViewModels(for type: InternalTransferAmountViewType) -> [OneListFlowItemViewModel] {
        switch type {
        case .noExchange:
            return []
        case .simpleExchange(let sell):
            return [amountListFlowItemViewModel(),
                    exchangeSellRateListFlowItemViewModel(value: sell),
                    receiveAmountListFlowItemViewModel()]
        case .doubleExchange(let sell, let buy):
            return [amountListFlowItemViewModel(),
                    exchangeBuyRateListFlowItemViewModel(value: buy),
                    exchangeSellRateListFlowItemViewModel(value: sell),
                    receiveAmountListFlowItemViewModel()]
        }
    }

    func amountListFlowItemViewModel() -> OneListFlowItemViewModel {
        return OneListFlowItemViewModel(items:
                                    [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "sendMoney_label_amount"), accessibilityId: "title"),
                                     OneListFlowItemViewModel.Item(type: .spacing(height: 4)),
                                     OneListFlowItemViewModel.Item(type: .custom(view: amountView), accessibilityId: "Item 0")
                                    ])
    }

    func exchangeBuyRateListFlowItemViewModel(value: String) -> OneListFlowItemViewModel {
        buyRateLabel.text = value
        return OneListFlowItemViewModel(items:
                                    [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "sendMoney_label_exchangeBuyRate"), accessibilityId: "title"),
                                     OneListFlowItemViewModel.Item(type: .custom(view: buyRateLabel), accessibilityId: "Item 1")
                                    ])
    }

    func exchangeSellRateListFlowItemViewModel(value: String) -> OneListFlowItemViewModel {
        sellRateLabel.text = value
        return OneListFlowItemViewModel(items:
                                    [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "sendMoney_label_exchangeSellRate"), accessibilityId: "title"),
                                     OneListFlowItemViewModel.Item(type: .custom(view: sellRateLabel), accessibilityId: "Item 2")
                                    ])
    }

    func receiveAmountListFlowItemViewModel() -> OneListFlowItemViewModel {
     return OneListFlowItemViewModel(isLastItem: true,
                             items:
                                [OneListFlowItemViewModel.Item(type: .title(keyOrValue: "sendMoney_label_recipientWillReceive"), accessibilityId: "title"),
                                 OneListFlowItemViewModel.Item(type: .spacing(height: 4)),
                                 OneListFlowItemViewModel.Item(type: .custom(view: receiveAmountView), accessibilityId: "Item 3"),
                                ])
    }

    func listFlowItemViewStackView(with viewModels: [OneListFlowItemViewModel]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        var indexPath = IndexPath(item: 0, section: 0)
        viewModels.forEach {
            let listFlowItem = OneListFlowItemView()
            listFlowItem.setupViewModel($0, at: indexPath)
            indexPath.row = indexPath.row + 1
            stackView.addArrangedSubview(listFlowItem)
        }
        return stackView
    }

    func setAccessibilityIdentifiers() {
        amountAndDateLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.amountAndDateTitleLabel.rawValue
        alertView.accessibilityIdentifier = AccessibilityInternalTransferAmount.alertViewLabel.rawValue
        sellRateLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.sellRateLabel.rawValue
        buyRateLabel.accessibilityIdentifier = AccessibilityInternalTransferAmount.buyRateLabel.rawValue
    }
}

// MARK: Binds
private extension InternalTransferAmountView {
    func bindAmountDidChange() {
        amountView.publisher
            .case ( ReactiveOneInputAmountViewState.textFieldDidChange )
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stateSubject.send(.didChangeAmount(self.amountView.getAmount()))
            }.store(in: &subscriptions)
    }

    func bindAmountDidEndEditing() {
        amountView.publisher
            .case ( ReactiveOneInputAmountViewState.textFieldDidEndEditing )
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stateSubject.send(.didEndEditingAmount)
            }.store(in: &subscriptions)
    }

    func bindWillReceiveDidChange() {
        receiveAmountView.publisher
            .case ( ReactiveOneInputAmountViewState.textFieldDidChange )
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stateSubject.send(.didChangeWillReceive(self.receiveAmountView.getAmount()))
            }.store(in: &subscriptions)
    }

    func bindWillReceiveDidEndEditing() {
        receiveAmountView.publisher
            .case ( ReactiveOneInputAmountViewState.textFieldDidEndEditing )
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stateSubject.send(.didEndEditingWillReceive)
            }.store(in: &subscriptions)
    }
}

// MARK: ReactiveInternalTransferAmountView
extension InternalTransferAmountView: ReactiveInternalTransferAmountView {
    public var publisher: AnyPublisher<InternalTransferAmountViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
