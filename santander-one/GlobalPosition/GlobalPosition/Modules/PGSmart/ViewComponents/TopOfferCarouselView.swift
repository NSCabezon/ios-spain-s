//
//  TopOfferCarouselView.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 5/7/21.
//

import UIKit
import CoreFoundationLib
import OfferCarousel

protocol TopOfferCarouselViewDelegate: AnyObject {
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?)
    func didSelectPullOffer(_ info: ExpirableOfferEntity)
}

final class TopOfferCarouselView: DesignableView {
    
    // MARK: - IBOutles
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Attributes
    
    private var cellsInfo: [PGCellInfo] = []
    private let supportedCells: [String] = []
    weak var delegate: TopOfferCarouselViewDelegate?
    private var dependenciesResolver: DependenciesResolver!
    var readyToAutoscroll = false
    
    // MARK: - Initializer
        
    // MARK: - Life cycle

    override func commonInit() {
        super.commonInit()
        self.registerCells()
    }
    
    // MARK: - Public methods
    
    func setOffers(_ offers: [PGCellInfo]) {
        self.cellsInfo = offers
        self.readyToAutoscroll = true
        self.tableView.reloadData()
    }
    
    func setDependeciesResolver(_ dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func reloadAllTable() {
        self.readyToAutoscroll = false
        self.tableView.reloadData()
    }
}

extension TopOfferCarouselView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = self.cellsInfo[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.cellClass, for: indexPath)
        (cell as? OfferCarouselTableViewCellProtocol)?.topCarouselInit(
            delegate: self,
            dependenciesResolver: self.dependenciesResolver,
            gpType: GlobalPositionConstants.smartPgType
        )
        if self.readyToAutoscroll {
            (cell as? OfferCarouselTableViewCellProtocol)?.resetNextIndex()
        }
        (cell as? OfferCarouselTableViewCellProtocol)?.setCellInfo(cellInfo.info as? OfferCarouselViewModel)
        (cell as? GeneralPGCellProtocol)?.setCellInfo(cellInfo.info)
        cell.layoutIfNeeded()
        return cell
    }
}

extension TopOfferCarouselView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellsInfo[indexPath.row].cellHeight
    }
}

private extension TopOfferCarouselView {
    private func registerCells() {
        self.supportedCells.forEach {
            self.tableView?.register(UINib(nibName: $0, bundle: Bundle(for: TopOfferCarouselView.self)), forCellReuseIdentifier: $0)
        }
        // Register OfferCarousel cell from outside Bundle
        self.tableView?.register(UINib(nibName: "OfferCarouselTableViewCell", bundle: BundleHelper.bundle), forCellReuseIdentifier: "OfferCarouselTableViewCell")

    }
}

extension TopOfferCarouselView: OfferCarouselTableViewCellDelegate {
    var enableSwipeTracking: Bool { true }

    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        self.delegate?.didSelectPregrantedBanner(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        self.delegate?.didSelectPullOffer(info)
    }
    
    func getPage() -> String {
        GlobalPositionConstants.carouselPageName
    }
    
    func getIdentifiers() -> [String: String] {
        ["carousel": "pgCarouselPullOffer",
         "pregranted": "pgCarouselPullOfferPregranted",
         "pullOffer": "pgCarouselPullOfferPGTopOffer"]
    }
}
