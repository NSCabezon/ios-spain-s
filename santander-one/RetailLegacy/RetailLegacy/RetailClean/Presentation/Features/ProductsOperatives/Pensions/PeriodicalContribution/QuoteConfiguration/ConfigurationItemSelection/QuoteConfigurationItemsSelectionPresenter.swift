protocol QuoteConfigurationItemsSelectionNavigatorProtocol {
    func selectionDone()
}

protocol SelectableConfigurationItem {
    func selectableType(stringLoader: StringLoader) -> QuoteConfigurationSelectableType
    func localizedTitle(stringLoader: StringLoader) -> LocalizedStylableText
    func localizedText(stringLoader: StringLoader) -> LocalizedStylableText
}

protocol QuoteConfigurationItemsSelectionPresenterDelegate: class {
    func isValidSelection(withOption option: SelectableConfigurationItem, value: String?) -> Bool
    func selectionSaved(withOption option: SelectableConfigurationItem, value: String?)
    func closeButton()
}

class QuoteConfigurationItemsSelectionPresenter: PrivatePresenter<QuoteConfigurationItemsSelectionViewController, QuoteConfigurationItemsSelectionNavigatorProtocol, QuoteConfigurationItemsSelectionPresenterProtocol> {
    
    var viewTitle: LocalizedStylableText? {
        get {
            return view.styledTitle
        }
        set {
            view.styledTitle = newValue
        }
    }
    var options = [SelectableConfigurationItem]() {
        didSet {
            if isViewLoaded {
                reloadOptions()
            }
        }
    }
    weak var delegate: QuoteConfigurationItemsSelectionPresenterDelegate?
    var selected = 0
    
    private var items = [QuoteConfigurationSelectableItemViewModel]()
    private var isViewLoaded = false
    
    override func loadViewData() {
        super.loadViewData()

        isViewLoaded = true
        reloadOptions()
    }
    
    func reloadOptions() {
        var i = 0
        for option in options {
            let viewModel = QuoteConfigurationSelectableItemViewModel(title: option.localizedTitle(stringLoader: stringLoader),
                                                                      type: option.selectableType(stringLoader: stringLoader),
                                                                      tag: i,
                                                                      radio: view.radio,
                                                                      isInitialIndex: i == selected,
                                                                      privateComponent: dependencies)
            items += [viewModel]
            i += 1
        }
        let section = TableModelViewSection()
        section.items = items
        view.sections = [section]
        view.confirmButtonTitle = stringLoader.getString("generic_button_validate")
        
        view.show(barButton: .close)
    }
}

extension QuoteConfigurationItemsSelectionPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        delegate?.closeButton()
    }
}

extension QuoteConfigurationItemsSelectionPresenter: QuoteConfigurationItemsSelectionPresenterProtocol {
    func selectedConfigurationItem(index: Int) {
        selected = index
    }

    func confirmButtonTouched() {
        let item = items[selected]
        let isValid = delegate?.isValidSelection(withOption: options[selected], value: item.view.text) ?? true
        guard isValid else {
            return
        }
        delegate?.selectionSaved(withOption: options[selected], value: item.view.text)
        navigator.selectionDone()
    }
}
