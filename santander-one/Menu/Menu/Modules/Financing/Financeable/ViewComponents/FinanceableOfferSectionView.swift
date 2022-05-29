import UIOneComponents
import UI
import UIKit

protocol FinanceableOfferSectionViewDelegate: AnyObject {
    func didSelectInPreconceivedBanner(_ viewModel: OfferEntityViewModel)
    func didSelectInRobinsonBanner(_ viewModel: OfferEntityViewModel)
    func didSelectInCommercialOfferBanner(_ viewModel: OfferEntityViewModel)
    func didSelectInAdobeTargetBanner(_ viewModel: AdobeTargetOfferViewModel)
}

final class FinanceableOfferSectionView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var gradientView: OneGradientView!
    
    private weak var delegate: FinanceableOfferSectionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configView(_ viewModel: FinanceableInfoViewModel,
                    delegate: FinanceableOfferSectionViewDelegate,
                    baseUrl: String?) {
        self.delegate = delegate
        removeArrangedSubviewsIfNeeded()
        addPreconceivedBannerIfNeeded(viewModel)
        addRobinsonOfferIfNeeded(viewModel)
        addCommercialOffersViewIfNeeded(viewModel, baseUrl: baseUrl)
        addAdobeTargetBannerIfNeeded(viewModel)
    }
}

private extension FinanceableOfferSectionView {
    func setupView() {
        backgroundColor = .white
        setGradient()
    }
    
    func setGradient() {
        gradientView.setupType(.oneGrayGradient(direction: GradientDirection.topToBottom))
    }

    func addPreconceivedBannerIfNeeded(_ viewModel: FinanceableInfoViewModel) {
        guard let needMoneyViewModel = viewModel.preconceivedBanner,
            let offer = needMoneyViewModel.offer else {
            return
        }
        let view = PreconceivedBannerView(frame: .zero)
        let viewModel = NeedMoneyViewModel(needMoneyViewModel)
        view.setViewModel(viewModel, delegate: self)
        stackView.addArrangedSubview(view)
    }
    
    func addRobinsonOfferIfNeeded(_ viewModel: FinanceableInfoViewModel) {
        guard let robinsonViewModel = viewModel.robinsonOffer,
              let offer = robinsonViewModel.offer
        else {
            return
        }
        let view = BigOfferFinanceableView(frame: .zero)
        let viewModel = BigOfferViewModel(robinsonViewModel)
        view.setViewModel(viewModel, delegate: self)
        view.setRobinsonOfferAccessibilityIdentifiers()
        view.type = .preconceived
        stackView.addArrangedSubview(view)
    }
    
    func addCommercialOffersViewIfNeeded(_ viewModel: FinanceableInfoViewModel, baseUrl: String?) {
        guard let commercialOffers = viewModel.commercialOffers,
              let offers = commercialOffers.offers,
              !offers.isEmpty
        else {
            return
        }
        let view = CommercialOffersView(frame: .zero)
        let viewModel = CommercialOffersViewModel(
            commercialOffers,
            baseUrl: baseUrl
        )
        view.configView(viewModel, delegate: self)
        stackView.addArrangedSubview(view)
    }
    
    func addAdobeTargetBannerIfNeeded(_ viewModel: FinanceableInfoViewModel) {
        guard let viewModel = viewModel.adobeTarget else {
            return
        }
        let view = AdobeTargetOfferView(frame: .zero)
        let adobeTargetViewModel = AdobeTargetOfferViewModel(viewModel)
        view.setViewModel(adobeTargetViewModel, delegate: self)
        stackView.addArrangedSubview(view)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension FinanceableOfferSectionView: PreconceivedBannerViewDelegate {
    func didSelectedBanner(_ viewModel: OfferEntityViewModel) {
        delegate?.didSelectInPreconceivedBanner(viewModel)
    }
}

extension FinanceableOfferSectionView: BigOfferFinanceableViewDelegate {
    func didSelectBigBanner(_ viewModel: OfferEntityViewModel) {
        delegate?.didSelectInRobinsonBanner(viewModel)
    }
}

extension FinanceableOfferSectionView: CommercialOffersViewDelegate {
    func didTapInOffer(_ viewModel: OfferEntityViewModel) {
        delegate?.didSelectInCommercialOfferBanner(viewModel)
    }
}

extension FinanceableOfferSectionView: AdobeTargetOfferViewDelegate {
    func didSelectedAdobeTargetBanner(_ viewModel: AdobeTargetOfferViewModel) {
        delegate?.didSelectInAdobeTargetBanner(viewModel)
    }
}
