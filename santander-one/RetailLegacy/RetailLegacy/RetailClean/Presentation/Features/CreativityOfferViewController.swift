import UIKit
import CoreDomain
import CoreFoundationLib

protocol CreativityOfferPresenterProtocol {
    var items: [CreativityCarouselCollectionViewModel] { get set }
    func execute(offerAction: OfferActionRepresentable?)
    func closeButtonPressed()
}

class CreativityOfferViewController: BaseViewController<CreativityOfferPresenterProtocol>, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var imageViewButton: ResponsiveButton!
    @IBOutlet weak var topImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var buttonStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var leftWhiteButton: WhiteButton!
    @IBOutlet weak var rightRedButton: RedButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override class var storyboardName: String {
        return "CreativityView"
    }
    
    override func prepareView() {
        super.prepareView()
        buttonContainerView.isHidden = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
    }
    
    func configure(topButton: OfferButton) {
        imageViewButton.onTouchAction = { [weak self] _ in
            self?.presenter.execute(offerAction: topButton.action)
        }
    }
    
    func configure(bottomButtons: [OfferButton]) {
        switch bottomButtons.count {
        case 0:
            buttonStackViewHeight.constant = 0
            rightRedButton.isHidden = true
            leftWhiteButton.isHidden = true
            buttonContainerView.isHidden = true
            
        case 1:
            let primaryAction = bottomButtons[0]
            
            rightRedButton.labelButtonLines()
            
            rightRedButton.setTitle(primaryAction.text.uppercased(), for: .normal)
            rightRedButton.onTouchAction = { [weak self] _ in
                self?.presenter.execute(offerAction: primaryAction.action)
            }
            rightRedButton.configureHighlighted(font: .latoBold(size: 14))
            rightRedButton.titleLabel?.textAlignment = .center
            rightRedButton.adjustTextIntoButton()
            
            rightRedButton.isHidden = false
            leftWhiteButton.isHidden = true
            
        default:
            let primaryAction = bottomButtons[0]
            
            rightRedButton.setTitle(primaryAction.text.uppercased(), for: .normal)
            rightRedButton.onTouchAction = { [weak self] _ in
                self?.presenter.execute(offerAction: primaryAction.action)
            }
            rightRedButton.configureHighlighted(font: .latoBold(size: 14))
            rightRedButton.labelButtonLines()
            rightRedButton.titleLabel?.textAlignment = .center
            rightRedButton.adjustTextIntoButton()
            
            rightRedButton.isHidden = false
            
            let secondAction = bottomButtons[1]
            
            leftWhiteButton.setTitle(secondAction.text.uppercased(), for: .normal)
            leftWhiteButton.onTouchAction = { [weak self] _ in
                self?.presenter.execute(offerAction: secondAction.action)
            }
            leftWhiteButton.configureHighlighted(font: .latoBold(size: 14))
            leftWhiteButton.labelButtonLines()
            leftWhiteButton.titleLabel?.textAlignment = .center
            leftWhiteButton.adjustTextIntoButton()
            
            leftWhiteButton.isHidden = false
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func updateTopButtonConstraint(_ newHeight: Float) {
        topImageViewHeight.constant = CGFloat(newHeight) - UIScreen.main.bounds.width * 0.3333
    }
    
    func setCarouselTotalElements(number: Int) {
        pageControl.isHidden = number <= 1
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .lisboaGray
        pageControl.currentPageIndicatorTintColor = .sanRed
        pageControl.numberOfPages = number
        pageControl.currentPage = 0
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
    
    @objc override func closeButtonTouched() {
        presenter.closeButtonPressed()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreativityCarouselCollectionViewCell", for: indexPath) as! CreativityCarouselCollectionViewCell
        presenter.items[indexPath.row].bind(viewCell: cell)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = view.bounds.width
        let currentPage = Int(offset/width)
        pageControl.currentPage = currentPage
    }
}
extension CreativityOfferViewController: ActionClosableProtocol {}
extension CreativityOfferViewController: NavigationBarCustomizable {}
