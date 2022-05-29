import UIKit
import OfferCarousel
import CoreFoundationLib

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Attributes
    
    private var cellsInfo: [OfferCarouselViewModel] = []
    internal var dependenciesResolver: DependenciesResolver & DependenciesInjector {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: TrackerManager.self) { _ in
            return TrackerManagerMock()
        }
        return defaultResolver
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        self.setOffers()
    }
}

private extension ViewController {
    private func registerCells() {
        // Register OfferCarousel cell from outside Bundle
        self.tableView?.register(UINib(nibName: "OfferCarouselTableViewCell", bundle: BundleHelper.bundle), forCellReuseIdentifier: "OfferCarouselTableViewCell")
    }
    
    private func setOffers() {
        let pregranted = PregrantedBannerViewModel(amount: 3.0, pregrantedBannerColor: .blue, pregrantedBannerText: "Test")
        let offerEntity = OfferEntity(OfferDTO(product: OfferProductDTO(identifier: "", neverExpires: false, transparentClosure: nil, description: "Test", rulesIds: [], iterations: 1, banners: [BannerDTO(app: "Test", height: 10, width: 10, url: "")], bannersContract: [], action: nil, startDateUTC: nil, endDateUTC: nil)))
        let offer1 = CarouselOfferViewModel(imgURL: "", height: nil, elem: offerEntity, transparentClosure: true)
        let offer2 = CarouselOfferViewModel(imgURL: "", height: nil, elem: offerEntity, transparentClosure: true)
        let elemens: [OfferCarouselViewModelType] = [.pregranted(pregranted), .offer(offer1), .offer(offer2)]
        let offerCarousel = OfferCarouselViewModel(elements: elemens)
        self.cellsInfo = [offerCarousel]
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = self.cellsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCarouselTableViewCell", for: indexPath)
        (cell as? OfferCarouselTableViewCellProtocol)?.topCarouselInit(
            delegate: self,
            dependenciesResolver: self.dependenciesResolver,
            gpType: ""
        )
        (cell as? OfferCarouselTableViewCellProtocol)?.setCellInfo(cellInfo)
        cell.layoutIfNeeded()
        return cell
    }
}

extension ViewController: OfferCarouselTableViewCellDelegate {
    var enableSwipeTracking: Bool {
        true
    }
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {}
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {}
    func getPage() -> String {return ""}
    func getIdentifiers() -> [String: String] { [:] }
}
