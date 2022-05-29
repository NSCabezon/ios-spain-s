//
//  PersonalAreaCollectionView.swift
//  PersonalArea
//
//  Created by Carlos Gutiérrez Casado on 23/12/2019.
//

import UI
import CoreDomain
import CoreFoundationLib
import Foundation

protocol PersonalAreaCollectionViewDelegate: AnyObject {
    func didSelectPageInfo(_ pageInfo: PageInfo)
    func didBegingScrolling()
    func didEndScrolling()
    func didEndScrollingSelectedItem()
}

class PersonalAreaCollectionView: UICollectionView {
    let cellIndentifier = "PersonalAreaCollectionViewCell"
    private let layout: ZoomAndSnapFlowLayout = ZoomAndSnapFlowLayout()
    
    weak var pageControlDelegate: PageControlDelegate?
    weak var personalAreaDelegate: PersonalAreaCollectionViewDelegate?
    
    private var currentSlides: [GeneralPageView] = []
    
    public var arrPageInfo = [PageInfo]() {
        didSet {
            createSlides()
        }
    }
    
    private var selectedIndexPathRow = 0
    
    let proportionalWidthSize: CGFloat = 0.6
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addLayout()
    }

    private func createSlides() {
        var slides: [GeneralPageView] = []
        arrPageInfo.forEach {
            let slide = GeneralPageView()
            slide.setInfo($0)
            slides.append(slide)
        }
        currentSlides = slides
    }
    
    private func setupView() {
        self.registerCell()
        self.addLayout()
        self.decelerationRate = .fast
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = .clear
    }
    
    private func addLayout() {
        let itemWidth = getProportionalItemSizeWidth()
        let itemHeight = getProportionalItemSizeHeight()
        layout.setItemSize(CGSize(width: itemWidth, height: itemHeight))
        layout.setMinimumLineSpacing(0.5)
        layout.setZoom(0)
        self.collectionViewLayout = layout
    }
    
    private func getProportionalItemSizeWidth() -> CGFloat {
        return self.bounds.size.height * proportionalWidthSize
    }
    
    private func getProportionalItemSizeHeight() -> CGFloat {
        return self.bounds.size.height
    }
    
    private func registerCell() {
        let nib = UINib(nibName: cellIndentifier, bundle: Bundle.module)
        self.register(nib, forCellWithReuseIdentifier: cellIndentifier)
    }
    
    private func notifySelectedPageInfo(_ pageInfo: PageInfo) {
        self.personalAreaDelegate?.didSelectPageInfo(pageInfo)
    }
    
}

extension PersonalAreaCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPageInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pageInfo = self.arrPageInfo[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIndentifier, for: indexPath) as? PersonalAreaCollectionViewCell {
            cell.configure(pageInfo)
            if selectedIndexPathRow != indexPath.row {
                cell.viewCell.selected(false)
                layoutSubviews()
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.personalAreaDelegate?.didBegingScrolling()
        let indexPathPoint = CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y)
        guard let indexPath = indexPathForItem(at: indexPathPoint) else { return }
        setPageSelected(indexPath)
        let pageInfo = arrPageInfo[indexPath.row]
        personalAreaDelegate?.didSelectPageInfo(pageInfo)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        personalAreaDelegate?.didEndScrolling()
    }
    
    func setPageSelected(_ indexPath: IndexPath) {
        selectedIndexPathRow = indexPath.row
        (self.cellForItem(at: IndexPath(row: indexPath.row - 1, section: 0)) as? PersonalAreaCollectionViewCell)?.viewCell.selected(false)
        (self.cellForItem(at: IndexPath(row: indexPath.row + 1, section: 0)) as? PersonalAreaCollectionViewCell)?.viewCell.selected(false)
        (self.cellForItem(at: indexPath) as? PersonalAreaCollectionViewCell)?.viewCell.selected(true)
        self.pageControlDelegate?.didPageChange(page: indexPath.item)
    }
    
    public func changeImageForSelectedPageView(imageNamed named: String, colorMode: PGColorMode) {
        (self.cellForItem(at: IndexPath(row: selectedIndexPathRow, section: 0) ) as? PersonalAreaCollectionViewCell)?.viewCell.changeBackgroundImage(imageNamed: named)
        (self.cellForItem(at: IndexPath(row: selectedIndexPathRow, section: 0) ) as? PersonalAreaCollectionViewCell)?.viewCell.selected(true)
        arrPageInfo[selectedIndexPathRow].imageName = named
        arrPageInfo[selectedIndexPathRow].smartColorMode = colorMode
    }
}
