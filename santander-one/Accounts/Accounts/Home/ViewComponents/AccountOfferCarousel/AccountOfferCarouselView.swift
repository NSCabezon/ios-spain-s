//
//  AccountOfferCarousel.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 27/7/21.
//

import UIKit
import CoreFoundationLib
import OfferCarousel
import UI

protocol AccountOfferCarouselViewDelegate: AnyObject {
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?)
    func didSelectPullOffer(_ info: ExpirableOfferEntity)
    func hideCarousel()
}

final class AccountOfferCarouselView: XibView {
    
    // MARK: - IBOutles
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Attributes
    
    private var cellsInfo: [OfferCarouselViewModel] = []
    weak var delegate: AccountOfferCarouselViewDelegate?
    private var dependenciesResolver: DependenciesResolver!
    var readyToAutoscroll = false
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.registerCells()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerCells()
    }
        
    // MARK: - Life cycle
    
    // MARK: - Public methods
    
    func setOffers(_ offers: [OfferCarouselViewModel]) {
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

extension AccountOfferCarouselView: UITableViewDataSource {
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
        if self.readyToAutoscroll {
            (cell as? OfferCarouselTableViewCellProtocol)?.resetNextIndex()
        }
        cell.layoutIfNeeded()
        return cell
    }
}

extension AccountOfferCarouselView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        48.0
    }
}

private extension AccountOfferCarouselView {
    func registerCells() {
        // Register OfferCarousel cell from outside Bundle
        self.tableView?.register(UINib(nibName: "OfferCarouselTableViewCell", bundle: BundleHelper.bundle), forCellReuseIdentifier: "OfferCarouselTableViewCell")
    }
    
    func hideViewIfIsNecessary() {
        if self.cellsInfo.count == 1 {
            if self.cellsInfo[0].elems.count == 1 {
                self.delegate?.hideCarousel()
            }
        }
    }
}

extension AccountOfferCarouselView: OfferCarouselTableViewCellDelegate {
    var enableSwipeTracking: Bool { false }
    
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        self.hideViewIfIsNecessary()
        self.delegate?.didSelectPregrantedBanner(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        self.hideViewIfIsNecessary()
        self.delegate?.didSelectPullOffer(info)
    }
    
    func getPage() -> String {
        AccountConstants.banners
    }
    
    func getIdentifiers() -> [String: String] {
        ["carousel": "accountCarouselPullOffer",
         "pregranted": "accountCarouselPullOfferPregranted",
         "pullOffer": "accountCarouselPullOfferPGTopOffer"]
    }
}
