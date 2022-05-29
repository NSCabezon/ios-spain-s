//
//  DigitalProfileCarrouselTableViewCell.swift
//  PersonalArea
//
//  Created by alvola on 10/12/2019.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain

final class DigitalProfileCarrouselTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var titleNumLabel: UILabel?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var separationView: UIView?
    
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    
    weak var digitalProfileDelegate: DigitalProfileViewProtocol?
    
    var cells: [DigitalProfileElemProtocol] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    private weak var delegate: DigitalProfileTableDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? DigitalProfileCarrouselCellModel else { return }
        titleLabel?.configureText(withLocalizedString: info.title,
                                  andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.0)))
        titleLabel?.accessibilityIdentifier = info.titleAccassibilityIdentifier
        titleNumLabel?.text = info.titleNum
        titleNumLabel?.accessibilityIdentifier = info.titleNumAccassibilityIdentifier
        cells = info.cells
    }
    
    private func commonInit() {
        configureView()
        configurelabels()
        configureCollectionView()
    }
    
    private func configureView() {
        selectionStyle = .none
        self.accessibilityIdentifier = AccessibilityDigitalProfilePendingCarousel.pendingCarouselBox
        separationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configurelabels() {
        titleLabel?.textColor = UIColor.lisboaGray
        titleNumLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14.0)
        titleNumLabel?.textColor = UIColor.lisboaGray
    }
    
    private func configureCollectionView() {
        collectionView?.register(UINib(nibName: "PersonalAreaCarrouselCollectionViewCell", bundle: Bundle.module), forCellWithReuseIdentifier: "PersonalAreaCarrouselCollectionViewCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.clipsToBounds = false
        collectionView?.decelerationRate = .fast
        collectionView?.accessibilityIdentifier = AccessibilityDigitalProfilePendingCarousel.pendingCarousel
        addLayout()
    }
    
    private func addLayout() {
        layout.setItemSize(CGSize(width: UIScreen.main.bounds.size.width - 60,
                                  height: collectionView?.frame.height ?? 0.0))
        layout.setMinimumLineSpacing(15)
        layout.setZoom(0)
        collectionView?.collectionViewLayout = layout
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 160.0)
    }
}

extension DigitalProfileCarrouselTableViewCell: DigitalProfileTableCellProtocol {
    func setCellDelegate(delegate: DigitalProfileTableDelegate?) {
        self.delegate = delegate
    }
}

extension DigitalProfileCarrouselTableViewCell: (UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout) {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonalAreaCarrouselCollectionViewCell", for: indexPath)
        (cell as? PersonalAreaCarrouselCollectionViewCell)?.setDesc(cells[indexPath.row].desc())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(item: cells[indexPath.row])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didSwipe()
    }
}
