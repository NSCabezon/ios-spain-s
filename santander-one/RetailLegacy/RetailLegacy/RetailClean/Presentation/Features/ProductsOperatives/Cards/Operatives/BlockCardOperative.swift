import Foundation
import CoreFoundationLib

class BlockCardOperative: Operative {
    
    var opinatorPage: OpinatorPage? {
        return .blockCard
    }
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    var isShareable = false
    var needsReloadGP = true
    var steps = [OperativeStep]()
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.backToPgFinishedNavigator
    }
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.BlockCardSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.BlockCardSummary().page
    }
  
    private var typeCardParameters: [String: String]? {
        guard let container = container else {
            return nil
        }
        let blockCard: BlockCardDetail = container.provideParameter()
        return [TrackerDimensions.cardType: blockCard.trackId]
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeCardParameters
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        guard let container = container else {
            return nil
        }
        let blockCard: BlockCardDetail = container.provideParameter()
        let selectTypeCardBlockTransaction: SelectTypeCardBlockTransaction = container.provideParameter()
        let blockCardStatusType = selectTypeCardBlockTransaction.blockCardStatusType.getCardBlockType
        var blockCardOperationType: String = ""
        switch blockCardStatusType {
        case .stolen, .lost:
            blockCardOperationType = "pérdida o robo"
        case .deterioration:
            blockCardOperationType = "deterioro"
        case .turnOn:
            blockCardOperationType = ""
        case .turnOff:
            blockCardOperationType = ""
        }
        return [TrackerDimensions.cardType: blockCard.trackId, TrackerDimensions.operationType: blockCardOperationType]
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeCardParameters
    }
    
    func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        
        add(step: factory.createStep() as SelectTypeBlockCard)
        add(step: factory.createStep() as OperativeSimpleSignature)
        add(step: factory.createStep() as OperativeSummary)
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let selectTypeCardBlockTransaction: SelectTypeCardBlockTransaction = container.provideParameter()
        
        let signatureFilled: SignatureFilled<Signature> = container.provideParameter()
        
        let blockCard: BlockCardDetail = container.provideParameter()
        let blockCardStatusType = selectTypeCardBlockTransaction.blockCardStatusType
        guard let blockTextString = selectTypeCardBlockTransaction.blockText else { return }
        
        let useCase = dependencies.useCaseProvider.confirmBlockCardUseCase(input: ConfirmBlockCardUseCaseInput(blockCard: blockCard, blockCardStatus: blockCardStatusType, blockText: blockTextString, signature: signatureFilled.signature))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { (response) in
            container.saveParameter(parameter: response.blockCardConfirm)
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        return dependencies.stringLoader.getString("summary_title_blockCard")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        guard let container = container else {
            return nil
        }
        let card: BlockCardDetail = container.provideParameter()
        let blockCardConfirm: BlockCardConfirm = container.provideParameter()
        
        let stringLoader = dependencies.stringLoader
        
        let itemBlockCard = SimpleSummaryData(field: stringLoader.getString("summary_item_blockCard"), value: card.card.getAliasAndInfo(), fieldIdentifier: "blockCardSummary_card_field", valueIdentifier: "blockCardSummary_card_value")
        let date = SimpleSummaryData(field: stringLoader.getString("summary_item_blockHour"), value: dependencies.timeManager.toStringFromCurrentLocale(date: Date(), outputFormat: TimeFormat.HHmm) ?? "", fieldIdentifier: "blockCardSummary_date_field", valueIdentifier: "blockCardSummary_date_value")
        
        if let deliveryAddress = blockCardConfirm.blockCardConfirmDTO.deliveryAddress, !deliveryAddress.isEmpty {
            let deliveryAddressString = SimpleSummaryData(field: stringLoader.getString("summary_item_delivery"), value: deliveryAddress.camelCasedString, fieldIdentifier: "blockCardSummary_delivery_field", valueIdentifier: "blockCardSummary_delivery_value")
            
            return [itemBlockCard, date, deliveryAddressString]
        }
        
        return [itemBlockCard, date]
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("summary_info_blockCard")
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
}

struct SelectTypeBlockCard: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.cardOperatives.selectTypeBlockCardPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
