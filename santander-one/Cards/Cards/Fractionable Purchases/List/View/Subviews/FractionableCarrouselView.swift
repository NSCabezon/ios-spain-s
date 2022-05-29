//
//  FractionableCarrouselView.swift
//  Cards
//
//  Created by alvola on 17/02/2021.
//

import CoreFoundationLib
import UI

protocol FractionableCarrouselViewDelegate: AnyObject {
    func showAllFractionableMovements()
    func didSelectElegiblePurchase(_ purchase: FractionableMovementCollectionViewModel)
    func didSelectViewMore()
    func didSwipe()
}

final class FractionableCarrouselView: UIView {
    
    weak var delegate: FractionableCarrouselViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.accessibilityIdentifier = "fractionatePurchases_title_footerDeferPurchases"
        label.configureText(withKey: "fractionatePurchases_title_footerDeferPurchases",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 15.0)))
        addSubview(label)
        return label
    }()
    
    private lazy var showAllLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 13.0)
        label.textColor = .white
        label.accessibilityIdentifier = "generic_button_seeAll"
        label.text = localized("generic_button_seeAll")
        label.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                          action: #selector(showAllPressed)))
        label.isUserInteractionEnabled = true
        addSubview(label)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 208.0, height: 120.0)
        let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.register(UINib(nibName: "FractionableMovementCollectionViewCell", bundle: Bundle.module),
                            forCellWithReuseIdentifier: "FractionableMovementCollectionViewCell")
        collection.register(UINib(nibName: "FractionableMovementsSeeAllCollectionViewCell", bundle: Bundle.module),
                            forCellWithReuseIdentifier: "FractionableMovementsSeeAllCollectionViewCell")
        collection.delegate = self
        collection.dataSource = self
        collection.clipsToBounds = false
        collection.showsHorizontalScrollIndicator = false
        addSubview(collection)
        return collection
    }()
    
    private var cells: [FractionableMovementCollectionViewModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setInfo(_ info: [FractionableMovementCollectionViewModel]) {
        self.cells = info
    }
}

private extension FractionableCarrouselView {
    func commonInit() {
        configureView()
        configureCollectionViewConstraints()
        configureTitleLabelConstraints()
        // TODO: uncomment this line when start working on https://sanes.atlassian.net/wiki/spaces/MOVPAR/pages/16412346112/Pago+f+cil+-+listado+todas+compras+fraccionables+desde+carrusel
//        configureShowAllLabelConstraints()
        collectionView.reloadData()
    }
    
    func configureView() {
        backgroundColor = .blueAnthracita
        accessibilityIdentifier = "fractionatePurchasesCarrousel"
        heightAnchor.constraint(equalToConstant: 200.0).isActive = true
    }
    
    func configureCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0),
            trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: 16.0),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 13.0),
            collectionView.heightAnchor.constraint(equalToConstant: 120.0)
        ])
    }
    
    func configureTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17.0),
            titleLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    func configureShowAllLabelConstraints() {
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: showAllLabel.trailingAnchor, constant: 19.0),
            showAllLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17.0),
            showAllLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    @objc func showAllPressed() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func seeAllCell(for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FractionableMovementsSeeAllCollectionViewCell", for: indexPath)
    }
}

extension FractionableCarrouselView: (UICollectionViewDataSource &
                                      UICollectionViewDelegate &
                                      UICollectionViewDelegateFlowLayout) {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < cells.count else { return seeAllCell(for: indexPath) }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FractionableMovementCollectionViewCell", for: indexPath)
        (cell as? FractionableMovementCollectionViewCell)?.setInfo(cells[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < cells.count else {
            delegate?.didSelectViewMore()
            return
        }
        delegate?.didSelectElegiblePurchase(cells[indexPath.row])
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didSwipe()
    }
}
