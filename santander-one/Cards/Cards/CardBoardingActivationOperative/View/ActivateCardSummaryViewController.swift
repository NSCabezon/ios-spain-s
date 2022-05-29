//
//  ActivateCardSummaryViewController.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/10/2020.
//

import Foundation
import UIKit
import UI
import Operative
import CoreFoundationLib

protocol ActivateCardSummaryViewProtocol: OperativeView {
    func showCard(viewModel: PlasticCardViewModel)
    func showOffers(offers: [OfferTipViewModel])
}

final class ActivateCardSummaryViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topShadow: UIView!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var offersCollectionView: UICollectionView!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var plasticCardView: PlasticCardView!
    let presenter: ActivateCardSummaryPresenterProtocol
    private var offers: [OfferTipViewModel] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ActivateCardSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let creditCardNib = UINib(nibName: "ActivateCardSummaryCell", bundle: Bundle.module)
        self.offersCollectionView.register(creditCardNib, forCellWithReuseIdentifier: "ActivateCardSummaryCell")
        self.offersCollectionView.delegate = self
        self.offersCollectionView.dataSource = self
        self.offersCollectionView.isHidden = true
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false 
        self.presenter.viewDidLoad()
        self.setupView()
        self.setAccessibilityIdentifier()
        self.removeTopNavigationInsets()
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

    private func setupView() {
        let bottomConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20),
        alignment: .center,
        lineHeightMultiple: 0.80,
        lineBreakMode: .byWordWrapping)
        self.backgroundImageView.image = Assets.image(named: "bgCardBoarding")
        self.titleLabel.textColor = .black
        self.titleLabel?.configureText(withKey: "cardBoarding_text_brilliant",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 30)))
        self.subTitleLabel.textColor = .black
        self.subTitleLabel?.configureText(withKey: "cardBoarding_title_activeCard",
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 26)))
        let continueButtonText = presenter.setContinueButtonText()
        self.continueButton.setTitle(localized(continueButtonText), for: .normal)
        self.bottomLabel.textColor = .lisboaGray
        self.bottomLabel.configureText(withKey: "cardBoarding_text_activeCard",
        andConfiguration: bottomConfiguration)
        self.bottomLabel.isHidden = !self.presenter.isBottomLabelVisible()
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
        layout.itemSize = CGSize(width: 192, height: 152)
        layout.minimumInteritemSpacing = 17
        layout.minimumLineSpacing = 17
        self.offersCollectionView.setCollectionViewLayout(layout, animated: false)
    }

    @objc private func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    @objc private func didSelectClose() {
        self.presenter.didSelectClose()
    }
    
    private func setAccessibilityIdentifier() {
        self.continueButton.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.continueButtonActivateCard
        self.titleLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.titleLabelActivateCard
        self.subTitleLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.subTitleLabelActivateCard
        self.bottomLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.bottomLabelActivateCard
        self.offersCollectionView.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.offersCollectionViewActivateCard
    }
}

extension ActivateCardSummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivateCardSummaryCell", for: indexPath) as? ActivateCardSummaryCell
            cell?.setImageWithUrl(self.offers[indexPath.row].imageUrl)
        cell?.setAccesibilityIdentifier(index: indexPath.row + 1)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectedOffer(self.offers[indexPath.row])
    }

}

extension ActivateCardSummaryViewController: ActivateCardSummaryViewProtocol {
    func showOffers(offers: [OfferTipViewModel]) {
        self.offers = offers
        if !self.offers.isEmpty {
            self.offersCollectionView.isHidden = false
            self.offersCollectionView.reloadData()
        }
    }
    
    func showCard(viewModel: PlasticCardViewModel) {
        self.plasticCardView.setViewModel(viewModel)
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
}

extension ActivateCardSummaryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
