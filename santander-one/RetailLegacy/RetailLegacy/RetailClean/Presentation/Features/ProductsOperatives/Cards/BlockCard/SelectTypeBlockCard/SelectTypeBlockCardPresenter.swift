import UIKit
import CoreFoundationLib

class SelectTypeBlockCardPresenter: OperativeStepPresenter<SelectTypeBlockCardViewController, VoidNavigator, SelectTypeBlockCardPresenterProtocol> {    
    private var blockCard: BlockCardDetail?
    private lazy var radio: RadioTable = RadioTable(delegate: self)
    
    var cardTitle: String? {
        return blockCard?.getAlias
    }
    
    var cardSubtitle: String? {
        guard let blockCard = blockCard, let pan = blockCard.getDetailUI.substring(blockCard.getDetailUI.count - 4) else {
            return nil
        }
        let panDescription = "***" + pan
        let key: String
        if blockCard.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if blockCard.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)]).text
    }
    
    var rightTitle: LocalizedStylableText? {
        guard let blockCard = blockCard else {
            return nil
        }
        if blockCard.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if blockCard.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return nil
        }
    }
    
    var amountText: String? {
        return blockCard?.amountUI
    }
    
    var cardImage: String? {
        return blockCard?.buildImageRelativeUrl(true)
    }
    
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        view.styledTitle = stringLoader.getString("toolbar_title_blockCard")
        
        guard let container = container else {
            return
        }
        blockCard = container.provideParameter()
        infoObtained()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.BlockCard().page
    }
    
    override func getTrackParameters() -> [String: String]? {
        return [TrackerDimensions.cardType: blockCard?.trackId ?? ""]
    }
    
    private func infoObtained() {
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        view.continueButton.onTouchAction = { [weak self] _ in
            self?.onContinueButtonClicked()
        }
        
        let sectionHeader = TableModelViewSection()
        let sectionContent = TableModelViewSection()
        
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                    subtitle: .plain(text: cardSubtitle),
                                                    rightTitle: rightTitle != nil ? rightTitle : .plain(text: ""),
                                                    amount: .plain(text: amountText),
                                                    imageURL: cardImage,
                                                    imageLoader: imageLoader)
        
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let modelViewTitleTableHeader = TitledTableModelViewHeader()
        modelViewTitleTableHeader.title = stringLoader.getString("blockCard_text_wearStole")
        modelViewTitleTableHeader.titleIdentifier = AccessibilityCardBlock.selectTitle
        sectionContent.setHeader(modelViewHeader: modelViewTitleTableHeader)
        
        let lossStolenModel = SelectTypeBlockCardModelView(statusType: .stolen, radio: radio, privateComponent: dependencies, inputIdentifier: "blockCard")
        
        let deteriorationModel = SelectTypeBlockCardModelView(statusType: .deterioration, radio: radio, privateComponent: dependencies, inputIdentifier: "blockCard")
        
        let infoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("blockCard_text_info"), style: LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 12), textAlignment: .center), titleIdentifier: "blockCard_info", privateComponent: dependencies)
        
        sectionContent.items += [lossStolenModel, deteriorationModel, infoLabelModel]
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func getModelViewSelected () -> SelectTypeBlockCardModelView? {
        guard let index = radio.indexSelected(), let section = getSection(section: index.section), let modelView = getModelView(section: section, row: index.row) else {
            return nil
        }
        return modelView
    }
    
    private func getTextForModelView(modelView: SelectTypeBlockCardModelView) -> String? {
        guard let text = modelView.field.text, !text.isEmpty else {
            return nil
        }
        return text
    }
    
    private func getSection (section: Int) -> TableModelViewSection? {
        guard view.sections.count > section else {
            return nil
        }
        return view.sections[section]
    }
    
    private func getModelView (section: TableModelViewSection, row: Int) -> SelectTypeBlockCardModelView? {
        guard section.items.count > row else {
            return nil
        }
        return section.items[row] as? SelectTypeBlockCardModelView
    }
}

class SelectTypeCardBlockTransaction: OperativeParameter {
    var blockText: String?
    var blockCardStatusType: BlockCardStatusType
    
    init(blockText: String?, blockCardStatusType: BlockCardStatusType) {
        self.blockText = blockText
        self.blockCardStatusType = blockCardStatusType
    }
}

// MARK: - SelectTypeBlockCardPresenterProtocol

extension SelectTypeBlockCardPresenter: SelectTypeBlockCardPresenterProtocol {
    
    func selected(index: IndexPath) {
        radio.didSelectCellComponent(indexPath: index)
    }
}

// MARK: - SelectTypeBlockCardPresenterProtocol

extension SelectTypeBlockCardPresenter: RadioTableDelegate {
    var tableComponent: UITableView {
        return view.tableView
    }
}

// MARK: - RadioTableActionDelegate

extension SelectTypeBlockCardPresenter: RadioTableActionDelegate {
    func auxiliaryButtonAction(tag: Int, completion: (_ action: RadioTableAuxiliaryAction) -> Void) {
        completion(.none)
    }
    
    func onContinueButtonClicked() {
        guard let container = self.container, let blockCard = self.blockCard else {
            return
        }
        
        guard let modelView = self.getModelViewSelected() else {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_error_radiobuttonNull")
            return
        }
        
        let blockText = self.getTextForModelView(modelView: modelView) ?? ""
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        performSelectTypeUseCase(blockCard: blockCard, container: container, blockText: blockText, blockCardStatus: modelView.statusType)
    }
    
    func performSelectTypeUseCase(blockCard: BlockCardDetail, container: OperativeContainerProtocol, blockText: String, blockCardStatus: BlockCardStatus) {
        guard let container = self.container as? OperativeContainer else {
            return
        }
        
        let caseInput = ValidateBlockCardUseCaseInput(blockCard: blockCard, blockCardStatus: BlockCardStatusType.create(blockCardStatus), blockText: blockText)
        UseCaseWrapper(with: useCaseProvider.validateBlockCardUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            
            guard let strongSelf = self else { return }
            container.saveParameter(parameter: blockCard)
            
            guard let signature = response.blockCard.signature else { return }
            container.saveParameter(parameter: signature)
            
            let selectTypeCardTransaction = SelectTypeCardBlockTransaction(blockText: blockText, blockCardStatusType: BlockCardStatusType.create(blockCardStatus))
            container.saveParameter(parameter: selectTypeCardTransaction)
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
            }, onError: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                })
        })
    }
}
