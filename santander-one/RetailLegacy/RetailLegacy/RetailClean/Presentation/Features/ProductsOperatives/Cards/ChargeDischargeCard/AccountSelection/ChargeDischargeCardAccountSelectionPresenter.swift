import Foundation
import CoreFoundationLib

class ChargeDischargeCardAccountSelectionPresenter: OperativeStepPresenter<ChargeDischargeCardAccountSelectionViewController, VoidNavigator, ChargeDischargeCardAccountSelectionPresenterProtocol> {
    
    private lazy var card: Card? = {
        let chargeDischargeData: ChargeDischargeCardOperativeData = containerParameter()
        return chargeDischargeData.productSelected
    }()
    
    private lazy var validList: AccountList? = {
        let chargeDischargeData: ChargeDischargeCardOperativeData = containerParameter()
        return chargeDischargeData.accountList
    }()
        
    var cardTitle: String? {
        return card?.getAlias()
    }
    var cardSubtitle: String? {
        guard let card = card else {
            return nil
        }
        let panDescription = card.getPANShort()
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)]).text
    }
    var rightTitle: LocalizedStylableText? {
        guard let card = card else {
            return nil
        }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return nil
        }
    }
    var amountText: String? {
        return card?.getAmountUI()
    }
    var cardImage: String? {
        return card?.buildImageRelativeUrl(true)
    }
    var imageLoader: ImageLoader {
        return dependencies.imageLoader
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.ChargeDischargeAccountSelection().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_chargeDischarge")
        infoObtained()
    }
    
    private func infoObtained() {
        let headerViewModel = GenericHeaderCardViewModel(title: .plain(text: cardTitle),
                                                    subtitle: .plain(text: cardSubtitle),
                                                    rightTitle: rightTitle != nil ? rightTitle : .plain(text: ""),
                                                    amount: .plain(text: amountText),
                                                    imageURL: cardImage,
                                                    imageLoader: imageLoader)
       
        let sectionHeader = TableModelViewSection()
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeCardHeaderView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        
        let sectionContent = TableModelViewSection()
        let titleTable = TitledTableModelViewHeader()
        titleTable.title = stringLoader.getString("chargeDischarge_text_originAccountSelection")
        titleTable.titleIdentifier = "chargeDischarge_accountList_title"
        sectionContent.setHeader(modelViewHeader: titleTable)
        
        if let accountsList = validList?.list {
            sectionContent.items = accountsList.map { SelectableAccountViewModel($0, baseIdentifier: AccessibilityCardChargeDischarge.accountCellBase, dependencies) }
        }

        view.sections = [sectionHeader, sectionContent]
    }
}

extension ChargeDischargeCardAccountSelectionPresenter: ChargeDischargeCardAccountSelectionPresenterProtocol {
    
    func selected(index: Int) {
        guard let modelView = view.itemsSectionContent()[index] as? SelectableAccountViewModel else {
            return
        }
        
        let chargeDischargeData: ChargeDischargeCardOperativeData = containerParameter()
        chargeDischargeData.account = modelView.account
        container?.saveParameter(parameter: chargeDischargeData)
        container?.stepFinished(presenter: self)
    }
}
