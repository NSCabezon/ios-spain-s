import UIKit
import UI
import CoreFoundationLib

public protocol CommercialOffersViewDelegate: AnyObject {
    func didTapInOffer(_ viewModel: OfferEntityViewModel)
}

public final class CommercialOffersView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var scrollableView: UIView!
    @IBOutlet private weak var itemsWidthConstraint: NSLayoutConstraint!

    private var scrollableStackView = HorizontalScrollableStackView(frame: .zero)
    private weak var delegate: CommercialOffersViewDelegate?
    var comercialOffers: FinanceableInfoViewModel.CommercialOffers?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func configView(_ viewModel: CommercialOffersViewModel,
                    delegate: CommercialOffersViewDelegate) {
        self.delegate = delegate
        let header = viewModel.commercialOfferEntity.header
        guard let headerTitle = header.title,
              let headerSubtitle = header.subtitle,
              let offersDto = viewModel.commercialOfferEntity.offers
        else {
            return
        }
        comercialOffers = viewModel.commercialOffers
        setTitleLabel(headerTitle)
        setSubtitleLabel(headerSubtitle)
        setCommercialOfferViewsIfNeeded(viewModel)
    }
}

private extension CommercialOffersView {
    func setupView() {
        backgroundColor = .clear
        configureScrollView()
        setAccessibilityIds()
    }
    
    func configureScrollView() {
        scrollableStackView.setup(with: self.scrollableView)
        scrollableStackView.enableScrollPagging(true)
        scrollableStackView.setBounce(enabled: false)
    }
    
    func setTitleLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, type: .bold, size: 18),
            alignment: .center,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .lisboaGray
    }
    
    func setSubtitleLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 14),
            alignment: .center,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        subtitleLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .brownishGray
    }
    
    func setCommercialOfferViews(_ viewModel: CommercialOffersViewModel) {
        guard let offers = viewModel.offers else {
            return
        }
        let itemWidthAnchor = getStackItemWidthAnchor(numOfItems: offers.count)
        offers.enumerated().forEach { (index, item) in
            if checkBanner(item.location.stringTag) {
                let viewModel = OfferEntityViewModel(entity: item.offer)
                let view = CommercialOffersBannerPillView()
                view.configView(viewModel,
                                delegate: self)
                view.heightAnchor.constraint(equalToConstant: CommercialOffersItemLayouts().heightAnchor).isActive = true
                view.widthAnchor.constraint(equalToConstant: itemWidthAnchor).isActive = true
                scrollableStackView.addArrangedSubview(view)
            } else {
                guard let hotOffers = viewModel.hotOffers else {
                    return
                }
                let offerEntityViewModel = OfferEntityViewModel(entity: item.offer)
                let offerPill = hotOffers[index]
                let view = CommercialOffersPillView()
                view.configView(baseURL: viewModel.baseUrl,
                                offerPill: offerPill,
                                viewModel: offerEntityViewModel,
                                delegate: self)
                view.heightAnchor.constraint(equalToConstant: CommercialOffersItemLayouts().heightAnchor).isActive = true
                view.widthAnchor.constraint(equalToConstant: itemWidthAnchor).isActive = true
                scrollableStackView.addArrangedSubview(view)
            }
        }
        setStackViewWidthAnchor(anchor: itemWidthAnchor,
                                numOfItems: offers.count)
    }
    
    func getStackItemWidthAnchor(numOfItems: Int) -> CGFloat {
        let numOfItems = CGFloat(numOfItems)
        let spacing: CGFloat = numOfItems > 1 ? CommercialOffersItemLayouts().widhtSpacing : 0
        let itemNominalWidth = UIScreen.main.bounds.width / CommercialOffersItemLayouts().maxItems
        let itemWidthAnchor = itemNominalWidth - CGFloat(spacing)
        return itemWidthAnchor
    }
    
    func setStackViewWidthAnchor(anchor: CGFloat, numOfItems: Int) {
        itemsWidthConstraint.constant = anchor * CGFloat(numOfItems)
    }
    
    func getOffer(_ location: String) -> OfferEntity? {
        guard let offers = self.comercialOffers?.offers else {
            return nil
        }
        let offer = offers.filter { $0.location.stringTag == location }.first
        return offer?.offer
    }
    
    func checkBanner(_ location: String) -> Bool {
        guard let offer = self.getOffer(location),
              let url = offer.banner?.url else {
            return false
        }
        return !url.isEmpty
    }
    
    func setCommercialOfferViewsIfNeeded(_ viewModel: CommercialOffersViewModel) {
        guard let offers = viewModel.offers, !offers.isEmpty else {
            return
        }
        setCommercialOfferViews(viewModel)
    }
    
    func setAccessibilityIds() {
        titleLabel.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.title
        subtitleLabel.accessibilityIdentifier = AccessibilityFinancingCommercialOffer.subtitle
    }
    
    struct CommercialOffersItemLayouts {
        let heightAnchor: CGFloat = 204
        let widhtSpacing: CGFloat = 8
        let maxItems: CGFloat = 2
    }
}

extension CommercialOffersView: CommercialOffersPillViewDelegate {
    public func didTapInOffer(_ viewModel: OfferEntityViewModel) {
        delegate?.didTapInOffer(viewModel)
    }
}
