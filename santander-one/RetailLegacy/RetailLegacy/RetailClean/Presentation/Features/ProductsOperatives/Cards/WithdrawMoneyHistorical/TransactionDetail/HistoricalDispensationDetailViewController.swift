import UIKit

protocol HistoricalDispensationDetailPresenterProtocol: Presenter {
    var dispensationDetailInfo: (ProductDetailInfoPresenter & ProductDetailProfileSeteable) { get }
}

class HistoricalDispensationDetailViewController: BaseViewController<HistoricalDispensationDetailPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var detailInfoContainer: UIView!
    
    override func prepareView() {
        super.prepareView()
        
        detailInfoContainer.backgroundColor = .uiBackground
        view.backgroundColor = .uiBackground
        plugIn(viewController: presenter.dispensationDetailInfo.view, inContainer: detailInfoContainer)
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
}

extension HistoricalDispensationDetailViewController: PluggerViewController {}
