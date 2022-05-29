import Foundation

class BaseTransferDetailData<T, Y> {
    let transferDetail: T
    let account: Account
    // defines if the detail was shown from account home with an account selected or not
    let originAccount: Account?
    let transfer: Y
    let sepaInfo: SepaInfoList
    let stringLoader: StringLoader
    let dependencies: PresentationComponent
    var toolTipDisplayer: ToolTipDisplayer?
    weak var shareDelegate: ShowShareType?
    
    init(transferDetail: T, account: Account, transfer: Y, sepaInfo: SepaInfoList, originAccount: Account?, toolTipDisplayer: ToolTipDisplayer? = nil, stringLoader: StringLoader, dependencies: PresentationComponent, shareDelegate: ShowShareType?) {
        self.transferDetail = transferDetail
        self.account = account
        self.transfer = transfer
        self.sepaInfo = sepaInfo
        self.stringLoader = stringLoader
        self.dependencies = dependencies
        self.toolTipDisplayer = toolTipDisplayer
        self.originAccount = originAccount
        self.shareDelegate = shareDelegate
    }
    
    func makeViewModels() -> [TableModelViewSection] {
        var result = [TableModelViewSection]()
        result.append(makeAccountSection())
        result.append(makeDetailSection(transferDetail: transferDetail, transfer: transfer))
        return result
    }
    
    func makeAccountSection() -> TableModelViewSection {
        fatalError()
    }
    
    func makeDetailSection(transferDetail: T, transfer: Y) -> TableModelViewSection {
        fatalError()
    }
    
    func buildHeader(with key: String) -> DetailTitleHeaderViewModel {
        let title = stringLoader.getString(key).uppercased()
        return DetailTitleHeaderViewModel(title: title, titleAccessibilityIdentifier: key)
    }
}
