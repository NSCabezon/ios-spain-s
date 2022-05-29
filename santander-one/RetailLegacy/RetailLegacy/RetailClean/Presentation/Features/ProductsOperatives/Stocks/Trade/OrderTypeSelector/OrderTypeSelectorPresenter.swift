import Foundation

class OrderTypeSelectorPresenter: TradeOperativeStepPresenter<OrderTypeSelectorViewController, VoidNavigator, OrderTypeSelectorPresenterProtocol> {
    var options: [StockTradeOrderType] = [.toMarket, .byBest, .byLimitation(amount: "")]
    var selected: Int?
    let sectionHeader = TableModelViewSection()

    // MARK: - Tracking

    override var screenId: String? {
        switch stockTradeData.order {
        case .buy:
            return TrackerPagePrivate.StocksBuyTypeOrder().page
        case .sell:
            return TrackerPagePrivate.StocksSellTypeOrder().page
        }
    }

    // MARK: -

    private var items = [OrderTypeItemViewModel]()
    
    override func loadViewData() {
        super.loadViewData()
        
        switch stockTradeData.order {
        case .buy:
            view.styledTitle = stringLoader.getString("toolbar_title_buyStock")
        case .sell:
            view.styledTitle = stringLoader.getString("toolbar_title_saleStock")
        }
        
        var i = 0
        for option in options {
            let viewModel = OrderTypeItemViewModel(title: option.localizedTitle(with: stringLoader),
                                                   type: option.radioOrderTypeItemType(with: stringLoader),
                                                    tag: i,
                                                    radio: view.radio,
                                                    isInitialIndex: i == selected,
                                                    privateComponent: dependencies)
            items += [viewModel]
            i += 1
        }
        let sectionContent = TableModelViewSection()
        sectionContent.items = items
        sectionContent.setHeader(modelViewHeader: titleSection())
        view.sections = [sectionHeader, sectionContent]
        view.confirmButtonTitle = stringLoader.getString("generic_button_continue")
        
        view.show(barButton: .close)
    }
    
    private func titleSection() -> TitledTableModelViewHeader {
        let sectionHeader = TitledTableModelViewHeader()
        sectionHeader.title = stringLoader.getString("buySale_text_kindOrder")
        return sectionHeader
    }
}

extension OrderTypeSelectorPresenter: OrderTypeSelectorPresenterProtocol {
    func headerLoaded(model: StockBaseHeaderViewModel) {
        let headerCell = GenericHeaderViewModel(viewModel: model, viewType: StockBaseHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
    }
    
    func tooltip(atIndex index: Int) -> (title: LocalizedStylableText, description: LocalizedStylableText) {
        return options[index].tooltip(with: stringLoader)
    }
    
    func selectedType(index: Int) {
        selected = index
    }
    
    func confirmButtonTouched() {
        guard let container = container, let selected = selected else {
            showError(keyTitle: "otp_titlePopup_error", keyDesc: "generic_error_radiobuttonNull", phone: nil, completion: nil)
            return
        }
        let item = items[selected]
        switch options[selected] {
        case .byLimitation:
            options[selected] = .byLimitation(amount: item.view.text ?? "")
        default:
            break
        }
        guard validate(optionIndex: selected) else {
            return
        }
        container.saveParameter(parameter: options[selected])
        container.stepFinished(presenter: self)
    }
    
    private func validate(optionIndex index: Int) -> Bool {
        let option = options[index]
        switch option {
        case .toMarket,
             .byBest:
            return true
        case .byLimitation(let value):
            switch Decimal.getAmountParserResult(value: value) {
            case .success:
                return true
            case .error(let error):
                let key: String
                switch error {
                case .null:
                    key = "buySale_allert_insertLimitOrder"
                case .notValid:
                    key = "buySale_allert_orderNoValid"
                case .zero:
                    key = "buySale_allert_limitOrderMore0"
                }
                showError(keyTitle: "generic_alert_title_errorData", keyDesc: key)
                return false
            }
        }
    }
}
