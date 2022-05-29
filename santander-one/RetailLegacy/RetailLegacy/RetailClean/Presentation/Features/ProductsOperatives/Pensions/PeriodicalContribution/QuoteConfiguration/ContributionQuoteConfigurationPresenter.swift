import Foundation

protocol ContributionQuoteConfigurationNavigatorProtocol {
    func goToSelection(title: LocalizedStylableText, options: [SelectableConfigurationItem], preselected: Int, delegate: QuoteConfigurationItemsSelectionPresenterDelegate)
}

enum ContributionConfigurationPeriodicity {
    case monthly
    case quarterly
    case biannual
    case annual
}

extension ContributionConfigurationPeriodicity: SelectableConfigurationItem {
    func selectableType(stringLoader: StringLoader) -> QuoteConfigurationSelectableType {
        return .empty
    }
    
    func localizedTitle(stringLoader: StringLoader) -> LocalizedStylableText {
        return localizedText(stringLoader: stringLoader)
    }
    
    func localizedText(stringLoader: StringLoader) -> LocalizedStylableText {
        switch self {
        case .monthly:
            return stringLoader.getString("periodicContribution_label_monthly")
        case .quarterly:
            return stringLoader.getString("periodicContribution_label_quarterly")
        case .biannual:
            return stringLoader.getString("periodicContribution_label_biannual")
        case .annual:
            return stringLoader.getString("periodicContribution_label_annual")
        }
    }
}

enum ContributionConfigurationRevaluation {
    case none
    case accordingToIPC
    case accordingToFixedPercentage(percentage: String)
}

extension ContributionConfigurationRevaluation: SelectableConfigurationItem {
    func selectableType(stringLoader: StringLoader) -> QuoteConfigurationSelectableType {
        switch self {
        case .none,
             .accordingToIPC:
            return .empty
        case .accordingToFixedPercentage(let percentage):
            return .percentage(placeholder: stringLoader.getString(""), value: percentage)
        }
    }
    func localizedTitle(stringLoader: StringLoader) -> LocalizedStylableText {
        switch self {
        case .accordingToFixedPercentage:
            return stringLoader.getString("periodicContribution_label_percentage")
        default:
            return localizedText(stringLoader: stringLoader)
        }
    }
    func localizedText(stringLoader: StringLoader) -> LocalizedStylableText {
        switch self {
        case .none:
            return stringLoader.getString("periodicContribution_label_withoutRevaluation")
        case .accordingToIPC:
            return stringLoader.getString("periodicContribution_label_ipc")
        case .accordingToFixedPercentage(let percentage):
            return stringLoader.getString("confirmation_label_fixedPercentage", [StringPlaceholder(.number, percentage)])
        }
    }
}

extension ContributionConfigurationRevaluation {
    //just same case without checking associated value
    public static func ~= (lhs: ContributionConfigurationRevaluation, rhs: ContributionConfigurationRevaluation) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
            
        case (.accordingToIPC, .accordingToIPC):
            return true
            
        case (.accordingToFixedPercentage, .accordingToFixedPercentage):
            return true
            
        default:
            return false
        }
    }
}

struct ContributionConfiguration {
    var periodicity: ContributionConfigurationPeriodicity
    var startDate: Date
    var revaluation: ContributionConfigurationRevaluation
}

extension ContributionConfiguration: OperativeParameter {}

class ContributionQuoteConfigurationPresenter: OperativeStepPresenter<ContributionQuoteConfigurationViewController, ContributionQuoteConfigurationNavigatorProtocol, ContributionQuoteConfigurationPresenterProtocol> {
    
    private var quoteConfigurationSection = TableModelViewSection()
    fileprivate lazy var amount: Amount? = {
        guard let container = container else {
            fatalError()
        }
        return container.provideParameter()
    }()
    
    private var configuration: ContributionConfiguration?
    
    private var periodicityOptions: [ContributionConfigurationPeriodicity] {
        return [.monthly, .quarterly, .biannual, .annual]
    }
    
    private var revaluationOptions: [ContributionConfigurationRevaluation] {
        var revaluation: [ContributionConfigurationRevaluation] = [.none, .accordingToIPC]
        
        if let configuration = configuration, case .accordingToFixedPercentage(let value) = configuration.revaluation {
            revaluation.append(.accordingToFixedPercentage(percentage: value))
        } else {
            revaluation.append(.accordingToFixedPercentage(percentage: ""))
        }
        return revaluation
    }
    
    enum ConfigurationItemIndex: Int {
        case periodicity = 0
        case startDate
        case revaluation
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_periodicContribution")
        view.confirmButtonTitle = stringLoader.getString("generic_button_continue")
        guard let container = container else { return }
        configuration = container.provideParameter()
        
        updateQuoteConfiguration()
    }
    
    private func updateQuoteConfiguration() {
        let sectionHeader = TableModelViewSection()
        let headerViewModel = GenericHeaderOneLineViewModel(leftTitle: stringLoader.getString("plansOption_button_periodicContribution"),
                                      rightTitle: .plain(text: amount?.getFormattedAmountUI()))
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderOneLineView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        let sectionTitleHeader = TitledTableModelViewHeader(
            insets: Insets(left: 11, right: 10, top: 15, bottom: 11)
        )
        sectionTitleHeader.title = stringLoader.getString("periodicContribution_text_settings")
        quoteConfigurationSection.setHeader(modelViewHeader: sectionTitleHeader)
        
        let periodicityItem = itemViewForPeriodicity()
        let startDateItem = itemViewForStartDate()
        let revaluationItem = itemViewForRevaluation()
        quoteConfigurationSection.items = [periodicityItem, startDateItem, revaluationItem]
        
        view.sections = [sectionHeader, quoteConfigurationSection]
    }
    
    private func itemViewForPeriodicity() -> ContributionQuoteConfigurationItemViewModel {
        
        let item = ContributionQuoteConfigurationItemViewModel(title: stringLoader.getString("periodicContribution_label_periodicity"),
                                                               value: configuration?.periodicity.localizedText(stringLoader: stringLoader).text ?? "",
                                                               order: .head,
                                                               privateComponent: dependencies)
        return item
    }
    
    private func itemViewForStartDate() -> ContributionQuoteConfigurationDateItemViewModel {
        let item = ContributionQuoteConfigurationDateItemViewModel(title: stringLoader.getString("periodicContribution_label_startDate"),
                                                                   date: configuration?.startDate ?? Date().firstOfNextMonth(),
                                                                   order: .middle,
                                                                   privateComponent: dependencies)
        return item
    }
    
    private func itemViewForRevaluation() -> ContributionQuoteConfigurationItemViewModel {
        let item = ContributionQuoteConfigurationItemViewModel(title: stringLoader.getString("periodicContribution_label_revaluation"),
                                                               value: configuration?.revaluation.localizedText(stringLoader: stringLoader).text ?? "",
                                                               order: .tail,
                                                               privateComponent: dependencies)
        return item
    }
}

extension ContributionQuoteConfigurationPresenter: ContributionQuoteConfigurationPresenterProtocol {    
    func selectedConfigurationItem(index: Int) {
        guard let item = ConfigurationItemIndex(rawValue: index) else {
            return
        }
        var title: LocalizedStylableText = .empty
        var options = [SelectableConfigurationItem]()
        var preselected = 0
        switch item {
        case .periodicity:
            title = stringLoader.getString("toolbar_title_periodicity")
            let periodicity = periodicityOptions
            options = periodicity
            guard let configuration = configuration, let selected = (periodicity.firstIndex { $0 == configuration.periodicity }) else {
                return
            }
            preselected = selected
        case .revaluation:
            title = stringLoader.getString("toolbar_title_revaluation")
            let revaluation = revaluationOptions
            options = revaluation
            guard let configuration = configuration, let selected = (revaluation.firstIndex { $0 ~= configuration.revaluation }) else {
                return
            }
            preselected = selected
        default:
            break
        }
        guard !options.isEmpty else {
            return
        }
        view.hideInputViews()
        navigator.goToSelection(title: title, options: options, preselected: preselected, delegate: self)
    }
    
    func setDate(date: Date, atIndex index: Int) {
        guard let container = container, let dateItem = quoteConfigurationSection.items[index] as? ContributionQuoteConfigurationDateItemViewModel else {
            return
        }
        configuration?.startDate = date
        dateItem.date = date
        if let configuration = configuration { container.saveParameter(parameter: configuration) }
    }
    
    func confirmButtonTouched() {
        if let configuration = configuration { container?.saveParameter(parameter: configuration) }
        container?.stepFinished(presenter: self)
    }
}

extension ContributionQuoteConfigurationPresenter: QuoteConfigurationItemsSelectionPresenterDelegate {
    func closeButton() {
        container?.cancelTouched(completion: nil)
    }
    
    func isValidSelection(withOption option: SelectableConfigurationItem, value: String?) -> Bool {
        if let revaluation = option as? ContributionConfigurationRevaluation {
            if case .accordingToFixedPercentage(_) = revaluation, case .error(let error) = Decimal.getPercentageParserResult(value: value) {
                let key = Decimal.defaultErrorDescriptionKey(forPercentageError: error)
                showError(keyDesc: key)
                return false
            }
        }
        return true
    }
    
    func selectionSaved(withOption option: SelectableConfigurationItem, value: String?) {
        if let periodicity = option as? ContributionConfigurationPeriodicity {
            configuration?.periodicity = periodicity
        } else if let revaluation = option as? ContributionConfigurationRevaluation {
            if case .accordingToFixedPercentage(_) = revaluation {
                switch Decimal.getPercentageParserResult(value: value) {
                case .error:
                    fatalError()
                case .success(let value):
                    configuration?.revaluation = .accordingToFixedPercentage(percentage: String(describing: value).replacingOccurrences(of: ".", with: ","))
                }
            } else {
                configuration?.revaluation = revaluation
            }
        }
        if let configuration = configuration { container?.saveParameter(parameter: configuration) }
        updateQuoteConfiguration()
    }
}
