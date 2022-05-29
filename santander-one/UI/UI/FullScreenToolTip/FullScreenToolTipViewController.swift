//
//  FullScreenToolTipViewController.swift
//  Tooltips
//
//  Created by Victor Carrilero García on 11/02/2020.
//  Copyright © 2020 Victor Carrilero García. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol ToolTipButtonDeRigueur: UIView {
    var tooltip: UIView? { get }
    var xCorrectionPadding: CGFloat { get }
}

public struct FullScreenToolTipViewItemData {
    let view: UIView
    let bottomMargin: CGFloat
    
    public init(view: UIView, bottomMargin: CGFloat) {
        self.view = view
        self.bottomMargin = bottomMargin
    }
}

public struct FullScreenToolTipViewData {
    let topMargin: CGFloat
    let stickyItems: [FullScreenToolTipViewItemData]
    let scrolledItems: [FullScreenToolTipViewItemData]
    let closeIdentifier: String?
    let containerIdentifier: String?
    let backgroundColor: UIColor
    let roundedCornes: CGFloat?
    let showCloseButton: Bool
    let dismissOutside: Bool
    
    public init(topMargin: CGFloat, stickyItems: [FullScreenToolTipViewItemData], scrolledItems: [FullScreenToolTipViewItemData], closeIdentifier: String? = nil, containerIdentifier: String? = nil, backgroundColor: UIColor = .white, roundedCornes: CGFloat? = nil, showCloseButton: Bool = true, dismissOutside: Bool = false) {
        self.topMargin = topMargin
        self.stickyItems = stickyItems
        self.scrolledItems = scrolledItems
        self.closeIdentifier = closeIdentifier
        self.containerIdentifier = containerIdentifier
        self.backgroundColor = backgroundColor
        self.roundedCornes = roundedCornes
        self.showCloseButton = showCloseButton
        self.dismissOutside = dismissOutside
    }
    
    @discardableResult
    public func show(in viewController: UIViewController, from: UIView?, isInitialToolTip: Bool? = nil, completion: (() -> Void)? = nil) -> FullScreenToolTipViewController {
        let fullScreenToolTipViewController = FullScreenToolTipViewController(nibName: "FullScreenToolTipViewController", bundle: .module)
        fullScreenToolTipViewController.origin = from
        fullScreenToolTipViewController.completionAction = completion
        fullScreenToolTipViewController.modalPresentationStyle = .overCurrentContext
        let animated = isInitialToolTip ?? false
        viewController.present(fullScreenToolTipViewController, animated: animated, completion: {
            fullScreenToolTipViewController.configure(data: self)
        })
        return fullScreenToolTipViewController
    }
}

public final class FullScreenToolTipViewController: UIViewController {
    @IBOutlet private var stickyStackview: Stackview!
    @IBOutlet private var scrolledStackview: Stackview!
    @IBOutlet private var stickyItemsScrollView: UIScrollView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var containerBackbroundView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var arrowView: LineTriangularView!
    @IBOutlet private var stickyStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var scrollviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var animatedViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var animatedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var closeImageview: UIImageView!
    @IBOutlet private var shadowView: UIView!
    @IBOutlet private var closeButton: UIButton!
    weak var origin: UIView?
    var completionAction: (()-> Void)?
    var customBackgrounColor: UIColor = .white
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.stickyStackview.delegate = self
        self.scrolledStackview.delegate = self
        self.scrollView.delegate = self
        setupView()
        setupOrigin(view: self.origin)
    }
    
    // MARK: - Internal methods
    func configure(data: FullScreenToolTipViewData) {
        self.customBackgrounColor = data.backgroundColor
        self.containerView.accessibilityIdentifier = data.containerIdentifier
        self.containerBackbroundView.backgroundColor = customBackgrounColor
        self.closeButton.accessibilityIdentifier = data.closeIdentifier
        self.closeButton.isHidden = data.showCloseButton == false
        self.closeImageview.isHidden = data.showCloseButton == false
        self.arrowView.customBackgroundColor = customBackgrounColor
        self.arrowView.setNeedsDisplay()
        self.reset()
        self.add(in: self.stickyStackview, space: data.topMargin)
        self.add(in: self.stickyStackview, items: data.stickyItems)
        self.add(in: self.scrolledStackview, items: data.scrolledItems)
        self.animatedViewBottomConstraint.isActive = true
        self.animatedViewHeightConstraint.isActive = false
        self.setupDismissOutside(shouldDismiss: data.dismissOutside)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.26)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.view.layoutSubviews()
            self?.resizeItemsIfNeeded()
        }
        
        guard let radius = data.roundedCornes else { return }
        self.setupCornes(radius: radius)
    }
}

// MARK: - Private Methods

private extension FullScreenToolTipViewController {
    @IBAction func closeView() {
        self.animatedViewBottomConstraint.isActive = false
        self.animatedViewHeightConstraint.isActive = true
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutSubviews()
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: { [weak self] in
                self?.completionAction?()
            })
        })
    }
    
    func add(in stackview: UIStackView, items: [FullScreenToolTipViewItemData]) {
        for index in 0..<items.count {
            let item = items[index]
            let itemView = item.view
            let bottomMargin = item.bottomMargin
            tint(view: itemView)
            stackview.addArrangedSubview(itemView)
            if #available(iOS 11.0, *), index != items.count - 1 {
                stackview.setCustomSpacing(bottomMargin, after: itemView)
            } else {
                self.add(in: stackview, space: bottomMargin)
            }
        }
        stackview.layoutIfNeeded()
    }
    
    func add(in stackview: UIStackView, element: UIView) {
        tint(view: element)
        stackview.addArrangedSubview(element)
    }
    
    func tint(view: UIView) {
        let color = customBackgrounColor
        view.backgroundColor = color
        view.subviews.forEach { [weak self] view in
            view.backgroundColor = color
            guard view.subviews.count != 0 else { return }
            self?.tint(view: view)
        }
    }
    
    func setupView() {
        self.view.backgroundColor = .clear
        self.arrowView.backgroundColor = .clear
        self.closeImageview.isAccessibilityElement = true
        self.closeImageview.image = Assets.image(named: "icnClose")
        self.containerView.layer.masksToBounds = false
        self.containerView.layer.shadowOffset = CGSize.zero
        self.containerView.layer.shadowRadius = 4
        self.containerView.layer.shadowOpacity = 0.25
        self.containerView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.0
        self.shadowView.layer.shadowRadius = 2
        self.stickyItemsScrollView.isScrollEnabled = false
    }
    
    func setupOrigin(view: UIView?) {
        guard
            let view = view,
            let window = view.window,
            let button = view as? ToolTipButtonDeRigueur,
            let tooltip = button.tooltip
        else { return }
        let originPoint = tooltip.convert(tooltip.bounds, to: window)
        self.arrowView.origin = originPoint.minX - (originPoint.maxX - originPoint.minX - button.xCorrectionPadding)
        self.containerViewTopConstraint.constant = originPoint.maxY
    }
    
    func add(in stackview: UIStackView, space: CGFloat) {
        let separatorView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: stackview.frame.size.width, height: space))
        separatorView.backgroundColor = UIColor.white
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: space).isActive = true
        self.add(in: stackview, element: separatorView)
    }
    
    func reset() {
        guard let stickyStackview = self.stickyStackview, let scrolledStackview = self.scrolledStackview else { return }
        self.reset(for: stickyStackview)
        self.reset(for: scrolledStackview)
    }
    
    func reset(for stackview: UIStackView) {
        for element in stackview.arrangedSubviews {
            stackview.removeArrangedSubview(element)
            element.removeFromSuperview()
        }
    }
    
    func resizeItemsIfNeeded() {
        scrolledStackview.subviews.forEach { ($0 as? ItemTooltipView)?.viewDidLayout() }
    }
    
    func setupDismissOutside(shouldDismiss: Bool) {
        guard shouldDismiss else { return }
        let tapToDismissGesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapToDismissGesture)
    }
    
    func setupCornes(radius: CGFloat) {
        self.containerBackbroundView.layer.cornerRadius = radius
        self.containerBackbroundView.clipsToBounds = true
    }
}

// MARK: FullScreenToolTipViewController

extension FullScreenToolTipViewController: StackviewDelegate {
    public func didChangeBounds(for stackview: UIStackView) {
        switch stackview {
        case self.stickyStackview:
            self.stickyStackViewHeightConstraint.constant = stackview.frame.size.height
        case self.scrolledStackview:
            self.scrollviewHeightConstraint.constant = stackview.frame.size.height
        default:
            break
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension FullScreenToolTipViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenToolTipViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shadowView.layer.shadowOpacity = scrollView.contentOffset.y <= 0 ? 0 : 0.4
    }
}

extension FullScreenToolTipViewController: NotSideMenuProtocol {}

// MARK: LineTriangularView
class LineTriangularView: UIView {
    public var customBackgroundColor: UIColor = .white
    var origin: CGFloat = 100 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    private let triangleSize: CGFloat = 10
    private let lineSize: CGFloat = 1
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let originPoint: CGFloat
        if origin - triangleSize - lineSize < 0 {
            originPoint = triangleSize + lineSize
        } else if origin + triangleSize + lineSize > rect.maxX {
            originPoint = rect.maxX - triangleSize - lineSize
        } else {
            originPoint = origin
        }
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: originPoint - triangleSize - lineSize, y: rect.maxY))
        path.addLine(to: CGPoint(x: originPoint, y: rect.maxY - triangleSize - lineSize))
        path.addLine(to: CGPoint(x: originPoint + triangleSize + lineSize, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        customBackgroundColor.setFill()
        path.fill()
        UIColor.lightGray.setStroke()
        path.stroke()
    }
}
