//
//  ExperiencesView.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 23/12/2019.
//

import UI
import CoreFoundationLib

final class ExperiencesView: DesignableView {
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var selectedExperience: ((_: ExperiencesViewModel) -> Void)?
    
    private var dataSource: [ExperiencesViewModel] = [] {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.reloadData()
        }
    }
    
    override func commonInit() {
        super.commonInit()
        configureView()
        configureImages()
    }
    
    func configureExperiences(with dataSource: [ExperiencesViewModel]) {
        self.dataSource = dataSource
    }

    // MARK: - privateMethods
}
private extension ExperiencesView {

    func configureView() {
        collectionView.setCollectionViewLayout(collectionViewLayout(), animated: false)
        collectionView.backgroundColor = UIColor.blueAnthracita
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView.register(UINib(nibName: "ExperiencesCollectionViewCell",
                                      bundle: Bundle(for: ExperiencesCollectionViewCell.self)),
                                forCellWithReuseIdentifier: "ExperiencesCollectionViewCell")
        backgroundColor = UIColor.blueAnthracita
        setAccessbilityIdentifiers()
    }
    
    func configureImages() {
        logoImageView.image = Assets.image(named: "logoSaExperiences")
    }
    
    func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: collectionView.frame.size.height,
                                 height: collectionView.frame.size.height * 0.913)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        return layout
    }
    
    func setAccessbilityIdentifiers() {
        self.logoImageView.isAccessibilityElement = true
        setAccessibility { self.logoImageView.isAccessibilityElement = false }
        self.logoImageView.accessibilityIdentifier = "logoSaExperiences"
        self.collectionView.accessibilityIdentifier = "collectionViewExperiences"
    }
}

extension ExperiencesView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExperiencesCollectionViewCell",
                                                             for: indexPath) as? ExperiencesCollectionViewCell
        else { return UICollectionViewCell() }
        cell.setViewModel(dataSource[indexPath.row])
        return cell
    }
}

extension ExperiencesView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < dataSource.count else { return }
        let viewModel = dataSource[indexPath.row]
        selectedExperience?(viewModel)
    }
}

extension ExperiencesView: AccessibilityCapable { }
