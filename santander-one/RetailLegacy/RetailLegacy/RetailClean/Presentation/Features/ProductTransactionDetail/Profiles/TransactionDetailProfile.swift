import Foundation
import CoreFoundationLib

typealias ProductAction = (title: LocalizedStylableText, index: Int)
typealias TransactionDetailInfo = (title: LocalizedStylableText, info: String)
typealias TransactionLine = (TransactionDetailInfo, TransactionDetailInfo?)

protocol TransactionDetailProfile: TrackerScreenProtocol {
    var productConfig: ProductConfig? { get set }
    var completionActions: ((_ options: [TransactionDetailActionType]) -> Void)? { get set }
    var title: String? { get }
    var alias: String? { get }
    var amount: String? { get }
    var showSeePdf: Bool? { get }
    var locations: [PullOfferLocation] { get }
    var titleLeft: LocalizedStylableText? { get }
    var nonDetailRowsToAppend: [TransactionLine]? { get }
    var infoLeft: String? { get }
    var titleRight: LocalizedStylableText? { get }
    var sideTitleText: LocalizedStylableText? { get }
    var sideDescriptionText: LocalizedStylableText? { get }
    var infoRight: String? { get }
    var singleInfoTitle: LocalizedStylableText? { get }
    var balance: String? { get }
    var showLoading: Bool? { get }
    var showActions: Bool? { get }
    var showShare: Bool? { get }
    var optionsDelegate: ProductOptionsDelegate? { get set }
    var delegate: (GenericTransactionDelegate & PullOfferActionsPresenter)? { get set }
    var navigationTitleKey: String { get }
    func requestTransactionDetail(completion: @escaping ([TransactionLine]?) -> Void)
    func getLocation() -> PullOfferLocation?
    func stringToShare() -> String?
    func seePDFDidTouched(completion: @escaping (Data?, StringErrorOutput?, PdfSource) -> Void)
    func showCompleteLoading()
    func hideLoading()
    func actionButton()
    func actionTitle(completion: @escaping (LocalizedStylableText?) -> Void)
    func candidatesLocations(_ locations: [PullOfferLocation: Offer])
}

extension TransactionDetailProfile {
    var nonDetailRowsToAppend: [TransactionLine]? {
        return nil
    }
    
    var navigationTitleKey: String {
        return "toolbar_title_moveDetail"
    }
    
    func seePDFDidTouched(completion: @escaping (Data?, StringErrorOutput?, PdfSource) -> Void) { }
    func showCompleteLoading() { }
    func hideLoading() { }
}

protocol FundTransactionProfileProtocol: TransactionDetailProfile {
    var isShowStatus: Bool? { get set }
    var status: LocalizedStylableText? { get set }
}
