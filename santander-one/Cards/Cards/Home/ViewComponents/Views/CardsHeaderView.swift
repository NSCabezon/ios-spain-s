//
//  CardsHeaderView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardsHeaderViewDelegate: AnyObject {
    func setHeightForNormalContent()
    func setHeightForFullContent()
    func didSelectCardViewModel(_ viewModel: CardViewModel)
    func didTapOnShareViewModel(_ viewModel: CardViewModel)
    func didTapOnCVVViewModel(_ viewModel: CardViewModel)
    func didTapOnActivateCard(_ viewModel: CardViewModel)
    func didSelectInformationButton(_ viewModel: CardViewModel, button: CardInformationButton)
    func didSelectMap()
    func didTapOnShowPAN(_ viewModel: CardViewModel)
    func isPANAlwaysSharable() -> Bool
}

protocol PageControlDelegate: AnyObject {
    func didPageChange(page: Int)
}

final class CardsHeaderView: XibView {
    weak var delegate: CardsHeaderViewDelegate?
    private var actionButtons: [ActionButton] = []
    @IBOutlet weak var actionButtonStackView: UIStackView!
    @IBOutlet weak var collectionView: CardsCollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    private var selectedViewModel: CardViewModel?
    @IBOutlet weak var informationContainerView: UIView!
    @IBOutlet weak var pageControlContainerView: UIView!
    @IBOutlet weak var informationButtonsView: InformationButtonView!
    @IBOutlet weak var actionsHeaderView: CardHeaderActionsView?
    @IBOutlet weak var stackView: UIStackView!
    var tagsContainerView: TagsContainerView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    private func setupView() {
        self.backgroundColor = UIColor.skyGray
        self.informationButtonsView.isHidden = true
        self.actionsHeaderView?.clipsToBounds = true
        self.setupPageControl()
        self.collectionView.pageControlDelegate = self
        self.collectionView.cardsDelegate = self
    }

    private func setupPageControl() {
        let pages = collectionView.numberOfItems(inSection: 0)
        self.updatePageControl(pages)
        self.pageControl.pageIndicatorTintColor = .silverDark
        self.pageControl.currentPageIndicatorTintColor = .botonRedLight
        self.pageControl.hidesForSinglePage = true
        if #available(iOS 14.0, *) {
            self.pageControlHeightConstraint.isActive = false
            self.pageControl.backgroundStyle = .minimal
        }
    }
    
    private func updatePageControl(_ numberOfItems: Int) {
        self.pageControl.numberOfPages = numberOfItems
        self.pageControl.isHidden = numberOfItems <= 1
        self.pageControl.currentPage = 0
    }
    
    func updateCardsViewModels(_ viewModels: [CardViewModel], selectedViewModel: CardViewModel) {
        self.updatePageControl(viewModels.count)
        self.collectionView.updateCardsViewModels(viewModels, selectedViewModel: selectedViewModel)
    }
    
    func updateCardViewModel(_ viewModel: CardViewModel) {
        self.selectedViewModel = viewModel
        self.collectionView.updateCardViewModel(viewModel)
    }
    
    func setCardActions(_ viewModels: [CardActionViewModel]) {
        self.removeAtionButtons()
        viewModels.forEach { (viewModel) in
            let cardAction = self.makeCardActionForViewModel(viewModel)
            self.actionButtons.append(cardAction)
        }
        self.addActionButtonToStackView()
    }
    
    func addTagContainer(withTags tags: [TagMetaData], delegate: TagsContainerViewDelegate) {
        let tagsContainerView = TagsContainerView()
        tagsContainerView.delegate = delegate
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.stackView.addArrangedSubview(tagsContainerView)
        tagsContainerView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        self.tagsContainerView = tagsContainerView
    }
    
    private func makeCardActionForViewModel(_ viewModel: CardActionViewModel) -> ActionButton {
        switch viewModel.actionType {
        case .applePay:
            return self.createApplePayActionButton(viewModel)
        default:
            return self.createActionButton(viewModel)
        }
    }
    
    private func setupActionButton(_ action: ActionButton, with viewModel: CardActionViewModel, renderingMode: UIImage.RenderingMode) {
        let copyModel = viewModel.copyViewModel(renderingMode: renderingMode)
        _ = copyModel.isFirstDays ? action.torquoiseAppearance() : action.grayAppearance()
        action.setExtraLabelContent(copyModel.highlightedInfo)
        action.setViewModel(copyModel)
        action.addSelectorAction(target: self, #selector(performCardAction))
        action.setIsDisabled(copyModel.isDisabled)
        action.accessibilityIdentifier = copyModel.accessibilityIdentifier
    }
    
    private func createActionButton(_ viewModel: CardActionViewModel) -> ActionButton {
        let action = ActionButton()
        self.setupActionButton(action, with: viewModel, renderingMode: .alwaysTemplate)
        return action
    }
    
    private func createApplePayActionButton(_ viewModel: CardActionViewModel) -> ActionButton {
        let action = ActionButton()
        self.setupActionButton(action, with: viewModel, renderingMode: .alwaysOriginal)
        action.isUserInteractionEnabled = viewModel.isUserInteractionEnable
        return action
    }
    
    @objc func performCardAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let cardActionViewModel = actionButton.getViewModel() as? CardActionViewModel else { return }
        cardActionViewModel.action?(cardActionViewModel.type, cardActionViewModel.entity)
    }
    
    private func removeAtionButtons() {
        self.actionButtons.forEach {
            $0.removeFromSuperview()
        }
        self.actionButtons.removeAll()
    }
    
    private func addActionButtonToStackView() {
        self.actionButtons.forEach {
            self.actionButtonStackView.addArrangedSubview($0)
        }
    }
    
    func addInformationButtonsForViewModel(_ viewModel: CardViewModel, hideCardsButtons: Bool) {
        if viewModel.isPrepaidCard || hideCardsButtons {
           self.updateViewWhoutInformationButtons()
        } else {
           self.updateViewWithInformationButtons(viewModel)
        }
    }
    
    func setPaymentMethod(_ description: LocalizedStylableText) {
        selectedViewModel?.paymentMethodDescription = description
        selectedViewModel?.isPaymentMethodSuccess = true
    }
    
    private func updateViewWhoutInformationButtons() {
        self.informationContainerView.isHidden = true
        self.layoutIfNeeded()
        self.delegate?.setHeightForNormalContent()
    }
    
    private func updateViewWithInformationButtons(_ viewModel: CardViewModel) {
        let buttonsView = InformationButtonFactory.getButtonsViewForViewModel(viewModel)
        self.informationButtonsView.rightButtonView = buttonsView.right
        self.informationButtonsView.leftButtonView = buttonsView.left
        self.assignInfoButtonsViewDelegates(infoButtonsView: informationButtonsView)
        self.informationContainerView.isHidden = false
        self.informationButtonsView.isHidden = false
        self.informationButtonsView.updateButtons()
        self.delegate?.setHeightForFullContent()
    }
    
    private func assignInfoButtonsViewDelegates(infoButtonsView: InformationButtonView) {
        if let infoView = infoButtonsView.leftButtonView as? MapButtonView {
            infoView.delegate = informationButtonsView
        }
        
        if let liquidationView = infoButtonsView.rightButtonView as? LiquidationButtonView {
            liquidationView.delegate = informationButtonsView
        }
        
        if let cashDispositionView = infoButtonsView.rightButtonView as? CashDispositionButtonView {
            cashDispositionView.delegate = informationButtonsView
        }
        
        if let changePaymentMethodView = infoButtonsView.rightButtonView as? ChangePaymentMethodFailView {
            changePaymentMethodView.delegate = informationButtonsView
        }
        
        if let changePaymentMethodView = infoButtonsView.rightButtonView as? ChangePaymentMethodSuccessView {
            changePaymentMethodView.delegate = informationButtonsView
        }
        if let settlementDetailButtonView = infoButtonsView.rightButtonView as? SettlementDetailButtonView {
            settlementDetailButtonView.delegate = informationButtonsView
        }
        if let emptySettlementButtonTapped = infoButtonsView.rightButtonView as? EmptySettlementButtonView {
            emptySettlementButtonTapped.delegate = informationButtonsView
        }
        infoButtonsView.informationButtonDelegate = self
    }
    
    private func handleOnTapCashDispositionAction() {
        if let viewModel = selectedViewModel {
            delegate?.didSelectInformationButton(viewModel, button: .cashDisposition)
        }
    }

    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let index = IndexPath(item: sender.currentPage, section: 0)
        self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }
}

extension CardsHeaderView: PageControlDelegate {
    func didPageChange(page: Int) {
        self.pageControl.currentPage = page
    }
}

extension CardsHeaderView: CardsCollectionViewDelegate {

    func didBeginScrolling() {
        self.setupActionButtons(enabled: false)
    }
    
    func didSelectCardViewModel(_ viewModel: CardViewModel) {
        self.selectedViewModel = viewModel
        self.delegate?.didSelectCardViewModel(viewModel)
        self.setupActionButtons(enabled: true)
    }
    
    func didTapOnShareViewModel(_ viewModel: CardViewModel) {
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
    
    func didTapOnCVVViewModel(_ viewModel: CardViewModel) {
        self.delegate?.didTapOnCVVViewModel(viewModel)
    }
    func didTapOnActivateCard(_ viewModel: CardViewModel) {
        self.delegate?.didTapOnActivateCard(viewModel)
    }
    
    func didTapOnShowPAN(_ viewModel: CardViewModel) {
        self.delegate?.didTapOnShowPAN(viewModel)
    }
    
    func isPANAlwaysSharable() -> Bool {
        return self.delegate?.isPANAlwaysSharable() ?? true
    }
}

extension CardsHeaderView: InformationButtonViewProtocol {
    func informationButtonTapped(button: CardInformationButton) {
        switch button {
        case .liquidation:
            Toast.show(localized("generic_alert_notAvailableOperation"))
        case .map:
            self.delegate?.didSelectMap()
        case .cashDisposition:
            self.handleOnTapCashDispositionAction()
        case .changePaymentMethod:
            guard let viewModel = self.selectedViewModel else { return }
            self.delegate?.didSelectInformationButton(viewModel, button: .changePaymentMethod)
        case .settlementDetail:
            guard let viewModel = self.selectedViewModel else { return }
            self.delegate?.didSelectInformationButton(viewModel, button: .settlementDetail)
        }
    }
}

extension CardsHeaderView: ProductHomeHeaderWithTagsViewProtocol {
    
    func updateHeaderAlpha(_ alpha: CGFloat) {
        self.actionsHeaderView?.fadePlushButton(alpha)
        self.collectionView.alpha = alpha
        self.pageControl.alpha = alpha
        self.informationButtonsView.alpha = alpha
        self.actionButtonStackView.alpha = alpha
    }
}

private extension CardsHeaderView {
    func setupActionButtons(enabled: Bool) {
        self.actionButtonStackView.isUserInteractionEnabled = enabled
        self.actionsHeaderView?.isUserInteractionEnabled = enabled
    }
}
