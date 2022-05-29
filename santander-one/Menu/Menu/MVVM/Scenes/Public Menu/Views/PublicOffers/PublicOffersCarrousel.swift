import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain
import CoreGraphics

enum PublicOffersCarrouselState: State {
    case idle
    case didSelectOffer(OfferRepresentable)
    case scrollViewDidEndDecelerating(Bool)
}

final class PublicOffersCarrousel: UICollectionView {

    private let layout = UICollectionViewFlowLayout()
    private var menuOptionRepresentable: PublicMenuOptionRepresentable?
    private var publicOfferElements: [PublicOfferElementRepresentable]?
    private let stateSubject = CurrentValueSubject<PublicOffersCarrouselState, Never>(.idle)
    let state: AnyPublisher<PublicOffersCarrouselState, Never>
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(frame: frame, collectionViewLayout: self.layout)
        self.commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func configure(publicMenuOption: PublicMenuOptionRepresentable, publicOfferElems: [PublicOfferElementRepresentable]) {
        self.menuOptionRepresentable = publicMenuOption
        self.publicOfferElements = publicOfferElems
        self.accessibilityIdentifier = publicMenuOption.accessibilityIdentifier
        reloadData()
    }
}

private extension PublicOffersCarrousel {
    
    func commonInit() {
        backgroundColor = .clear
        configureCollectionView()
    }
    
    func configureCollectionView() {
        register(PublicOfferCarrouselCell.self,
                 forCellWithReuseIdentifier: "PublicOfferCarrouselCell")
        delegate = self
        dataSource = self
        clipsToBounds = false
        showsHorizontalScrollIndicator = false
        self.accessibilityIdentifier = AccessibilityPublicMenuButtons.offerCarousel
        addLayout()
    }
    
    func addLayout() {
        layout.itemSize = CGSize(width: 176.0,
                                 height: 103.0)
        layout.scrollDirection = .horizontal
        collectionViewLayout = layout
    }
}

extension PublicOffersCarrousel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < publicOfferElements?.count ?? 0,
              let offer = publicOfferElements?[indexPath.row].offerRepresentable else { return }
        self.stateSubject.send(.didSelectOffer(offer))
    }
}

extension PublicOffersCarrousel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publicOfferElements?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PublicOfferCarrouselCell", for: indexPath) as? PublicOfferCarrouselCell,
              let info = publicOfferElements?[indexPath.row]
        else { return UICollectionViewCell() }
        cell.setImageURL(info.imageURL)
        cell.setTitle(info.titleKey)
        cell.setAccessibilityIdentifiers()
        return cell
    }
}

extension PublicOffersCarrousel: UICollectionViewDelegateFlowLayout {

    var collectionViewSectionSeparation: CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         CGSize(width: 176, height: 103)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        self.collectionViewSectionSeparation
    }
}

extension PublicOffersCarrousel: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stateSubject.send(.scrollViewDidEndDecelerating(true))
    }
}
