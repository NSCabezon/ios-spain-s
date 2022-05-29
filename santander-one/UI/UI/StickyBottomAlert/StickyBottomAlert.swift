//
//  StickyBottomAlert.swift
//  UI
//
//  Created by alvola on 23/06/2020.
//

import UIKit

public protocol StickyBottomAlertDelegate: AnyObject {
    func dismissed()
}

public protocol StickyExpandedViewProtocol: UIView {
    func setInfo(_ info: Any)
}

public protocol StickyCollapsedViewProtocol: UIView {
    func setInfo(_ info: Any)
}

public protocol ExpandedViewActionsProtocol {
    func presentAction()
    func dismissAction()
    func superDismissAction(block: @escaping () -> Void)
}

public final class StickyBottomAlert: UIView {
    
    private struct StickyViewConstants {
        var height: CGFloat = 244
        var collapsedBottomMargin: CGFloat {
            let total = height - collapsedHeight
            return self.bottomPadding == 0 ? total : total - 20.0 + self.bottomPadding
        }
        var bottomPadding: CGFloat {
            let window = UIApplication.shared.keyWindow
            if #available(iOS 11.0, *) {
                return window?.safeAreaInsets.bottom ?? 0.0
            }
            return 0.0
        }
        var totalCollapsedViewHeight: CGFloat {
            return bottomPadding + collapsedHeight
        }
        var collapsedHeight: CGFloat = 20.0
        let expandedTopViewHeight: CGFloat
        
        init(expandedHeight: CGFloat, collapsedHeight: CGFloat, expandedTopViewHeight: CGFloat) {
            self.height = expandedHeight
            self.collapsedHeight = collapsedHeight
            self.expandedTopViewHeight = expandedTopViewHeight
        }
    }
    
    public static func otpNotificationMode() -> StickyBottomAlert {
        let alert = StickyBottomAlert(constants: StickyViewConstants(expandedHeight: 244,
                                                                     collapsedHeight: 20,
                                                                     expandedTopViewHeight: 46.0))
        alert.addCollapsedViewOfType(OTPCodeCollapsedView.self)
        alert.addExpandedViewOfType(OTPCodeView.self)
        return alert
    }
    
    public static func recoveryAlertMode() -> StickyBottomAlert {
        let alert = StickyBottomAlert(constants: StickyViewConstants(expandedHeight: 183,
                                                                     collapsedHeight: 49,
                                                                     expandedTopViewHeight: 29.0))
        alert.addCollapsedViewOfType(RecoveryCollapsedView.self)
        alert.addExpandedViewOfType(RecoveryExpandedView.self)
        alert.dismissButton.isHidden = true
        return alert
    }
    
    private lazy var topView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var dismissButton: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnCloseLayer"))
        image.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(image)
        image.accessibilityIdentifier = "icnCloseLayer"
        image.topAnchor.constraint(equalTo: self.topView.topAnchor, constant: 6.0).isActive = true
        image.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -13.0).isActive = true
        image.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        image.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDismissButtonTouched)))
        image.isUserInteractionEnabled = true
        return image
    }()
    
    private var collapsedView: StickyCollapsedViewProtocol?
    private var expandedView: StickyExpandedViewProtocol? {
        didSet {
            (expandedView as? ExpandedViewActionsProtocol)?.superDismissAction { [weak self] in
                self?.dismiss()
            }
        }
    }
    private var bottomMargin: NSLayoutConstraint?
    private var movementOriginY: CGFloat = 0.0
    private lazy var viewOriginYWhenStartingMovement: CGFloat = 0.0
    private var isExpanded: Bool = true
    
    private var constants: StickyViewConstants
    
    public weak var delegate: StickyBottomAlertDelegate?
    
    private init(constants: StickyViewConstants) {
        self.constants = constants
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
        self.topView.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
        self.collapsedView?.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
    }
    
    public func show(in view: UIView) {
        self.add(toSuperview: view)
        self.addGestureRecognizer()
        self.superview?.layoutIfNeeded()
        self.showAnimated(delay: 1.0)
    }
    
    public func setExpandedInfo(_ info: Any) {
        expandedView?.setInfo(info)
    }
    
    public func setCollapsedInfo(_ info: Any) {
        collapsedView?.setInfo(info)
    }
    
    public func addExpandedViewOfType<T: StickyExpandedViewProtocol>(_ type: T.Type) {
        let view = T(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addExpandedView(view)
    }
    
    public func addCollapsedViewOfType<T: StickyCollapsedViewProtocol>(_ type: T.Type) {
        let view = T(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.0
        addCollapsedView(view)
    }
    
    public func addExpandedView(_ view: StickyExpandedViewProtocol) {
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topView.bottomAnchor).isActive = true
        
        self.expandedView = view
    }
    
    public func addCollapsedView(_ view: StickyCollapsedViewProtocol) {
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: constants.totalCollapsedViewHeight).isActive = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandView)))
        self.collapsedView = view
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        dismissAnimated(completion: completion)
    }
    
    public func showDismissButton(_ show: Bool) {
        dismissButton.isHidden = !show
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
        default:
            break
        }
    }
    
    @objc public func expandView() {
        showAnimated(delay: 0.5)
    }
}

private extension StickyBottomAlert {
    
    func gestureDidBegin(withLocation location: CGPoint) {
        self.viewOriginYWhenStartingMovement = self.bottomMargin?.constant ?? 0.0
        self.movementOriginY = location.y
    }
    
    func gestureDidUpdate(withLocation location: CGPoint) {
        let bottomMargin = max(0, self.viewOriginYWhenStartingMovement + location.y - self.movementOriginY)
        self.bottomMargin?.constant = bottomMargin
    }
    
    func gestureDidFinish() {
        let half = constants.height / 2
        let currentPosition = self.bottomMargin?.constant ?? 0.0
        let isExpanded = half > currentPosition
        let animation = isExpanded ? self.setupExpandedView() : self.setupCollapsedView()
        UIView.animate(withDuration: 0.2, animations: animation)
    }
    
    typealias AnimationBlock = () -> Void
    
    func setupExpandedView() -> AnimationBlock {
        self.bottomMargin?.constant = 0
        return {
            self.collapsedView?.alpha = 0.0
            self.expandedView?.alpha = 1.0
            self.superview?.layoutIfNeeded()
        }
    }
    
    func setupCollapsedView() -> AnimationBlock {
        self.bottomMargin?.constant = constants.collapsedBottomMargin
        return {
            self.collapsedView?.alpha = 1.0
            self.expandedView?.alpha = 0.0
            self.superview?.layoutIfNeeded()
        }
    }
    
    func add(toSuperview view: UIView) {
        view.addSubview(self)
        updateBottomMarginConstraint(inView: view)
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: constants.height + constants.bottomPadding).isActive = true
    }
    
    func updateBottomMarginConstraint(inView view: UIView) {
        var oldConstant: CGFloat?
        if bottomMargin != nil {
            oldConstant = bottomMargin?.constant
            bottomMargin?.isActive = false
            bottomMargin = nil
        }
        bottomMargin = self.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                    constant: oldConstant ?? constants.height + constants.bottomPadding)
        bottomMargin?.isActive = true
    }
    
    func addGestureRecognizer() {
        let swipe = UIPanGestureRecognizer()
        swipe.addTarget(self, action: #selector(move))
        self.addGestureRecognizer(swipe)
    }
    
    func setAppearance() {
        self.backgroundColor = .white
        self.configureTopView()
        self.addShadow(location: .top, opacity: 0.4, height: 1)
    }
    
    func configureTopView() {
        self.topView.backgroundColor = .white
        self.topView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.topView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.topView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.topView.heightAnchor.constraint(equalToConstant: constants.expandedTopViewHeight).isActive = true
        
        configureToggleButton()
        showDismissButton(true)
        setNeedsLayout()
    }
    
    func configureToggleButton() {
        let toggleButton = UIView(frame: .zero)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.backgroundColor = UIColor.lightSanGray
        toggleButton.layer.cornerRadius = 2.0
        toggleButton.accessibilityIdentifier = "toggleButton"
        toggleButton.widthAnchor.constraint(equalToConstant: 27.0).isActive = true
        toggleButton.heightAnchor.constraint(equalToConstant: 4.0).isActive = true
        let touchContainer = toggleButton.embedIntoView(topMargin: 9, bottomMargin: 9, leftMargin: 9, rightMargin: 9)
        touchContainer.translatesAutoresizingMaskIntoConstraints = false
        self.topView.addSubview(touchContainer)
        touchContainer.topAnchor.constraint(equalTo: self.topView.topAnchor, constant: 0).isActive = true
        touchContainer.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor).isActive = true
        touchContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToggleButton)))
    }
    
    func showAnimated(delay: CGFloat) {
        let action = self.setupExpandedView()
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: action) { [weak self] _ in
            (self?.expandedView as? ExpandedViewActionsProtocol)?.presentAction()
        }
    }
    
    func hideAnimated(completion: (() -> Void)?) {
        self.bottomMargin?.constant = constants.height + constants.bottomPadding
        UIView.animate(withDuration: 0.5, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { success in
            guard success else { return }
            self.isHidden = true
            completion?()
        })
    }
    
    @objc func onDismissButtonTouched() {
        dismissAnimated()
    }
    
    @objc func didTapToggleButton() {
        UIView.animate(withDuration: 0.5, animations: self.setupCollapsedView())
    }
    
    func dismissAnimated(completion: (() -> Void)? = nil) {
        (self.expandedView as? ExpandedViewActionsProtocol)?.dismissAction()
        hideAnimated { [weak self] in
            self?.removeFromSuperview()
            self?.delegate?.dismissed()
            completion?()
        }
    }
}
