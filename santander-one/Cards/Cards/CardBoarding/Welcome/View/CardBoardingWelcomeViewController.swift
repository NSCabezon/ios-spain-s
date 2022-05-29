//
//  CardBoardingWelcomeViewController.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 12/11/2020.
//

import Foundation
import UIKit
import UI
import Operative
import CoreFoundationLib

protocol CardBoardingWelcomeViewProtocol: AnyObject {
    func showCard(viewModel: PlasticCardViewModel)
    func showOffers(_ offers: [OfferTipViewModel])
}

final class CardBoardingWelcomeViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topShadow: UIView!
    @IBOutlet private weak var offersCollectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var plasticCardView: PlasticCardView!
    let presenter: CardBoardingWelcomePresenterProtocol
    private var offers: [OfferTipViewModel] = []
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardBoardingWelcomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupView()
        self.navigationController?.disablePopGesture()
    }
    
    func removeTopNavigationInsets() {
        guard #available(iOS 11.0, *) else {
            self.automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .darkTorquoise),
            title: .none
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.title(title: localized("generic_buttom_noThanks"), action: #selector(didSelectClose), font: .santander(family: .text, type: .regular, size: 15), accessibilityIdentifier: "generic_buttom_noThanks")
        )
        builder.build(on: self, with: nil)
    }
}

private extension CardBoardingWelcomeViewController {
    
    func setupView() {
        let creditCardNib = UINib(nibName: "CardBoardingWelcomeCell", bundle: Bundle.module)
        self.offersCollectionView.register(creditCardNib, forCellWithReuseIdentifier: "CardBoardingWelcomeCell")
        self.offersCollectionView.delegate = self
        self.offersCollectionView.dataSource = self
        self.offersCollectionView.isHidden = true
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.setAccessibilityIdentifier()
        self.removeTopNavigationInsets()
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20),
                                                                    alignment: .center,
                                                                    lineHeightMultiple: 0.80,
                                                                    lineBreakMode: .byWordWrapping)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.configureText(withKey: "cardBoarding_text_customizeCard",
                                      andConfiguration: titleConfiguration)
        self.backgroundImageView.image = Assets.image(named: "bgCardBoarding")
        self.continueButton.setTitle(localized("cardBoarding_button_customizeCard"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        self.offersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.setCollectionViewFlowLayout()
        self.plasticCardView.increaseFontScaleBy(1.3)
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
    
    func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 230, height: 182)
        layout.minimumInteritemSpacing = 21
        layout.minimumLineSpacing = 21
        self.offersCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    func setAccessibilityIdentifier() {
        self.continueButton.accessibilityIdentifier = AccesibilityCardsCardBoardingWelcome.continueButton
        self.titleLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingWelcome.titleLabel
        self.offersCollectionView.accessibilityIdentifier = AccesibilityCardsCardBoardingWelcome.offersCollectionView
    }
    
    @objc func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }
}

extension CardBoardingWelcomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardBoardingWelcomeCell", for: indexPath) as? CardBoardingWelcomeCell
        cell?.setImageWithUrl(self.offers[indexPath.row].imageUrl)
        cell?.setAccesibilityIdentifier(index: indexPath.row + 1)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let offer = self.offers[indexPath.row].representable.offerRepresentable else { return }
        presenter.didSelectOffer(offer)
    }
}

extension CardBoardingWelcomeViewController: CardBoardingWelcomeViewProtocol {
    func showOffers(_ offers: [OfferTipViewModel]) {
        self.offers = offers
        if !self.offers.isEmpty {
            self.offersCollectionView.isHidden = false
            self.offersCollectionView.reloadData()
        }
    }
    
    func showCard(viewModel: PlasticCardViewModel) {
        self.plasticCardView.setViewModel(viewModel)
    }
}

extension CardBoardingWelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
