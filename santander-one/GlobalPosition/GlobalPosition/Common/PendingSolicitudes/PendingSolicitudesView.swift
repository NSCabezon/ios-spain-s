//
//  PendingSolicitudesView.swift
//  GlobalPosition
//
//  Created by José Carlos Estela Anguita on 31/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol PendingSolicitudesViewDelegate: AnyObject {
    func pendingSolicitudesViewIsShown(_ height: CGFloat)
    func pendingSolicitudesIsClosed()
}

protocol PendingSolicitudesViewProtocol: AnyObject {
    func hide(completion: (() -> Void)?)
    func showPendingSolicitudes(_ pendingSolicitudes: [StickyButtonCarrouselViewModelProtocol])
    func expandView()
    func observeBecomeActive()
}

final class PendingSolicitudesView: UIView {
    
    var view: UIView?
    @IBOutlet private weak var collectionView: PendingSolicitudesCollectionView!
    @IBOutlet private weak var leftScrollButton: UIButton!
    @IBOutlet private weak var rightScrollButton: UIButton!
    @IBOutlet private weak var collapseIndicatorContainer: UIView!
    @IBOutlet private weak var collapseIndicatorView: UIView!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    private var presenter: PendingSolicitudesPresenterProtocol?
    private var bottomMargin: NSLayoutConstraint?
    private var movementOriginY: CGFloat = 0.0
    private lazy var viewOriginYWhenStartingMovement: CGFloat = 0.0
    private lazy var collapsedView: PendingSolicitudesCollapsedView = {
        let view = PendingSolicitudesCollapsedView(frame: .zero)
        view.alpha = 0.0
        view.delegate = self
        return view
    }()
    private var isExpanded: Bool {
        let half = Constants.height / 2
        let currentPosition = self.bottomMargin?.constant ?? 0.0
        return half > currentPosition
    }
    weak var delegate: PendingSolicitudesViewDelegate?
    
    private enum Constants {
        static let height: CGFloat = 145
        static var collapsedBottomMargin: CGFloat {
            if self.bottomPadding == 0 {
                return 100
            } else {
                return 80 + self.bottomPadding
            }
        }
        static var bottomPadding: CGFloat {
            let window = UIApplication.shared.keyWindow
            if #available(iOS 11.0, *) {
                return window?.safeAreaInsets.bottom ?? 0.0
            }
            return 0.0
        }
        static let collapsedViewHeight: CGFloat = 45
        static let collapsedViewAndShadowPaddingHeight: CGFloat = collapsedViewHeight + bottomPadding / 2
    }
    
    convenience init(presenter: PendingSolicitudesPresenterProtocol) {
        self.init(frame: .zero)
        self.presenter = presenter
        self.collectionView.pendingSolicitudesDelegate = self
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.setAppearance()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.topView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        self.collapsedView.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        self.view?.addShadow(location: .top, opacity: 0.4, height: 1)
        self.presenter?.viewDidLoad()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    func showWhenLoaded(in view: UIView) {
        self.presenter?.shouldShow { [weak self] shouldShow in
            guard shouldShow else { return }
            self?.delegate?.pendingSolicitudesViewIsShown(Constants.collapsedViewAndShadowPaddingHeight)
            self?.add(toSuperview: view)
            self?.addGestureRecognizer()
            self?.addCollapsedView()
            self?.superview?.layoutIfNeeded()
            self?.showAnimated(delay: 1.0)
        }
    }
    
    func update() {
        guard self.isHidden else { return }
        self.presenter?.shouldShow {  [weak self] shouldShow in
            guard shouldShow else { return }
            self?.isHidden = false
            self?.showAnimated(delay: 0.5)
        }
    }
    
    @objc func move(sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: self)
        switch sender.state {
        case .began:
            self.gestureDidBegin(withLocation: location)
        case .changed:
            self.gestureDidUpdate(withLocation: location)
        case .ended:
            self.gestureDidFinish()
        case .cancelled:
            self.gestureDidFinish()
        default:
            break
        }
    }
    
    @IBAction func collectionLeftScroll(_ sender: Any) {
        guard let min = self.collectionView.indexPathsForVisibleItems.min() else { return }
        self.collectionView.scrollToItem(at: min, at: .centeredHorizontally, animated: true)
        self.highlightCell(at: min)
    }
    
    @IBAction func collectionRightScroll(_ sender: Any) {
        guard let max = self.collectionView.indexPathsForVisibleItems.max() else { return }
        self.collectionView.scrollToItem(at: max, at: .centeredHorizontally, animated: true)
        self.highlightCell(at: max)
    }
}

private extension PendingSolicitudesView {
    
    func highlightCell(at indexPath: IndexPath) {
        for visibleCell in self.collectionView.visibleCells {
            let cell = visibleCell as? PendingSolicitudeCollectionViewCell
            cell?.setBackgroundColor(.oneSkyGray)
            cell?.setBorderColor(.oneBrownGray, shadowColor: .clear)
        }
        let cell = self.collectionView.cellForItem(at: indexPath) as? PendingSolicitudeCollectionViewCell
        cell?.setBackgroundColor(.oneWhite)
        cell?.setBorderColor(.oneMediumSkyGray, shadowColor: .oneLightSanGray)
    }
}

extension PendingSolicitudesView: XibInstantiable {
    
    var bundle: Bundle? {
        return Bundle(for: PendingSolicitudesView.self)
    }
}

extension PendingSolicitudesView: PendingSolicitudesViewProtocol {
    
    func observeBecomeActive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(becomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func showPendingSolicitudes(_ pendingSolicitudes: [StickyButtonCarrouselViewModelProtocol]) {
        self.collectionView.setViewModels(pendingSolicitudes)
        self.setCollapsedText(pendingSolicitudes)
    }
    
    func hide(completion: (() -> Void)?) {
        self.hideAnimated(completion: completion)
    }
    
    func expandView() {
        guard !isExpanded else { return }
        self.showAnimated(delay: 0.0)
    }
}

extension PendingSolicitudesView: PendingSolicitudesCollectionViewDelegate {
    
    func pendingSolicitudeClosed(_ viewModel: PendingSolicitudeViewModel) {
        self.presenter?.pendingSolicitudeClosed(viewModel)
    }
    
    func pendingSolicitudeSelected(_ viewModel: PendingSolicitudeViewModel) {
        self.presenter?.pendingSolicitudeSelected(viewModel)
    }
    
    func offerSelected(_ offer: OfferEntity) {
        self.presenter?.offerSelected(offer)
    }
}

private extension PendingSolicitudesView {
    
    @objc func becomeActive() {
        self.setNeedsDisplay()
    }
    
    func setCollapsedText(_ viewModels: [StickyButtonCarrouselViewModelProtocol]) {
        if let recovery = viewModels.first as? RecoveryViewModel {
            self.collapsedView.setTitleNumber(recovery.debtCount, style: CollapsedLabelStyle.recovery)
        } else {
            self.collapsedView.setTitleNumber(viewModels.count, style: CollapsedLabelStyle.pendingRequest)
        }
    }
    
    func gestureDidBegin(withLocation location: CGPoint) {
        self.viewOriginYWhenStartingMovement = self.bottomMargin?.constant ?? 0.0
        self.movementOriginY = location.y
    }
    
    func gestureDidUpdate(withLocation location: CGPoint) {
        let bottomMargin = max(0, self.viewOriginYWhenStartingMovement + location.y - self.movementOriginY)
        self.bottomMargin?.constant = bottomMargin
    }
    
    func gestureDidFinish() {
        let animation = isExpanded ? self.setupExpandedView() : self.setupCollapsedView()
        UIView.animate(withDuration: 0.2, animations: animation)
    }
    
    typealias AnimationBlock = () -> Void
    
    func setupExpandedView() -> AnimationBlock {
        self.bottomMargin?.constant = 0
        return {
            self.collectionView.alpha = 1.0
            self.collapsedView.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }
    }
    
    func setupCollapsedView() -> AnimationBlock {
        self.bottomMargin?.constant = Constants.collapsedBottomMargin
        return {
            self.collectionView.alpha = 0.0
            self.collapsedView.alpha = 1.0
            self.superview?.layoutIfNeeded()
        }
    }
    
    func add(toSuperview view: UIView) {
        view.addSubview(self)
        if self.bottomMargin == nil {
            self.bottomMargin = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Constants.height + Constants.bottomPadding)
        }
        self.bottomMargin?.isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: Constants.height + Constants.bottomPadding).isActive = true
    }
    
    func addCollapsedView() {
        self.addSubview(self.collapsedView)
        self.collapsedView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.collapsedView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.collapsedView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.collapsedView.heightAnchor.constraint(equalToConstant: Constants.collapsedViewHeight).isActive = true
    }
    
    func addGestureRecognizer() {
        let swipe = UIPanGestureRecognizer()
        swipe.addTarget(self, action: #selector(move))
        self.addGestureRecognizer(swipe)
    }
    
    func setAppearance() {
        self.view?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.bottomView.backgroundColor = .white
        self.topView.backgroundColor = .white
        self.collapseIndicatorView.layer.cornerRadius = self.collapseIndicatorView.frame.height / 2
        self.collapseIndicatorView.backgroundColor = .lightSanGray
        self.collapseIndicatorContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCollapseIndicatorView)))
        self.setAccessibilityIdentifier()
    }
    
    func showAnimated(delay: CGFloat) {
        let action = self.setupExpandedView()
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: action, completion: nil)
    }
    
    func hideAnimated(completion: (() -> Void)?) {
        self.bottomMargin?.constant = Constants.height + Constants.bottomPadding
        self.delegate?.pendingSolicitudesIsClosed()
        UIView.animate(withDuration: 0.5, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { success in
            guard success else { return }
            self.isHidden = true
            completion?()
        })
    }
    
    @objc func didTapCollapseIndicatorView() {
        UIView.animate(withDuration: 0.5, animations: self.setupCollapsedView())
    }
    
    func setAccessibilityIdentifier() {
        self.collapseIndicatorContainer.accessibilityIdentifier = AccessibilityRecoveredMoney.collapseIndicatorContainer
        self.collapseIndicatorView.accessibilityIdentifier =  AccessibilityRecoveredMoney.collapseIndicatorView
        self.leftScrollButton.accessibilityIdentifier = AccessibilityRecoveredMoney.leftScroll
        self.rightScrollButton.accessibilityIdentifier = AccessibilityRecoveredMoney.rightScroll
    }
}

extension PendingSolicitudesView: PendingSolicitudesCollapsedViewDelegate {
    
    func didSelectPendingSolicitudesCollapsedView() {
        self.showAnimated(delay: 0.0)
    }
}
