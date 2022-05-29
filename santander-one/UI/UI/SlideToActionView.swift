//
//  SlideToActionView.swift
//  UI
//
//  Created by César González Palomino on 08/12/2020.
//

import Foundation
import UIKit

public enum SlideToActionStyle {
    case `default`
    case easyPay
    public var sliderCornerRadius: CGFloat {
        switch self {
        case .default:
            return 8.0
        case .easyPay:
            return 5.0
        }
    }
    public var sliderBackgroundColor: UIColor {
        switch self {
        case .default:
            return .blueAnthracita
        case .easyPay:
            return .skyGray
        }
    }
    public var frontTextColor: UIColor {
        switch self {
        case .default:
            return .greenishBeige
        case.easyPay:
            return .santanderRed
        }
    }
    public var backTextColor: UIColor {
        switch self {
        case .default:
            return .red
        case.easyPay:
            return .white
        }
    }
    public var slidingColor: UIColor {
        switch self {
        case .default:
            return .coolGray
        case.easyPay:
            return .santanderRed
        }
    }
    public var thumbnailColor: UIColor {
        switch self {
        case .default:
            return .atmsShadowGray
        case.easyPay:
            return .clear
        }
    }

    private var defaultTextFont: UIFont { .santander(family: .text, type: .regular, size: 15.0) }
    public var frontTextFont: UIFont { defaultTextFont }
    public var backTextFont: UIFont { defaultTextFont }
}

public protocol SlideToActionDelegateProtocol: AnyObject {
    func slideToActionDidFinish(_ sender: SlideToActionView)
}

public final class SlideToActionView: UIView {
    
    private let frontTitleLabel = UILabel()
    private let backTitleLabel = UILabel()
    public let thumnailImageView = UIImageView()
    private let sliderHolderView = UIView()
    private let draggedView = UIView()
    private let view =  UIView()
    
    public weak var delegate: SlideToActionDelegateProtocol?
    private var animationVelocity: Double = 0.2

    public var isEnabled = true {
        didSet { animationChangedEnabledBlock?(isEnabled) }
    }
    
    public var showSliderText = true {
        didSet { backTitleLabel.isHidden = !showSliderText }
    }
    
    public var shouldDimFrontText = false
    
    public var animationChangedEnabledBlock: ((Bool) -> Void)?
    private var style: SlideToActionStyle
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var xEndingPoint: CGFloat {
        return view.frame.maxX - thumnailImageView.bounds.width
    }
    private var isFinished = false
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    override public init(frame: CGRect) {
        self.style = .default
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.style = .default
        super.init(coder: aDecoder)!
    }
    
    convenience public init(frontText: String?,
                            backText: String?,
                            image: UIImage? = nil,
                            style: SlideToActionStyle = .easyPay,
                            addShadow: Bool = true,
                            delegate: SlideToActionDelegateProtocol? = nil) {
        self.init(frame: .zero)
        frontTitleLabel.text = frontText
        backTitleLabel.text = backText
        self.thumnailImageView.image = image
        self.style = style
        self.delegate = delegate
        if addShadow { configureShadow() }
        setupView()
    }
    
    public func resetStateWithAnimation(_ animated: Bool) {
        let action = {
            self.leadingThumbnailViewConstraint?.constant = 0.0
            self.frontTitleLabel.alpha = 1
            self.layoutIfNeeded()
            self.isFinished = false
        }
        if animated {
            UIView.animate(withDuration: animationVelocity) {
               action()
            }
        } else {
            action()
        }
    }
}

private extension SlideToActionView {
    
    func setupView() {
        addSubview(view)
        thumnailImageView.isUserInteractionEnabled = true
        thumnailImageView.contentMode = .scaleAspectFill
        
        view.addSubview(sliderHolderView)
        sliderHolderView.addSubview(frontTitleLabel)
        view.addSubview(draggedView)
        draggedView.addSubview(backTitleLabel)
        
        view.addSubview(thumnailImageView)
        setupConstraint()
        setStyle()
        configureStyle()
        // Add pan gesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        thumnailImageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func configureStyle() {
        sliderHolderView.layer.cornerRadius = style.sliderCornerRadius
        draggedView.layer.cornerRadius = style.sliderCornerRadius
        sliderHolderView.backgroundColor = style.sliderBackgroundColor
        backTitleLabel.textColor = style.backTextColor
        frontTitleLabel.textColor = style.frontTextColor
        draggedView.backgroundColor = style.slidingColor
        thumnailImageView.backgroundColor = style.thumbnailColor
        frontTitleLabel.font = style.frontTextFont
        backTitleLabel.font = style.backTextFont
    }
    
    func configureShadow() {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 1.3
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        
        thumnailImageView.layer.shadowColor = UIColor.black.cgColor
        thumnailImageView.layer.shadowOpacity = 0.3
        thumnailImageView.layer.shadowRadius = 4.0
        thumnailImageView.layer.shadowOffset = CGSize(width: -2, height: 0)
    }
    
    func setupConstraint() {
        view.translatesAutoresizingMaskIntoConstraints = false
        thumnailImageView.translatesAutoresizingMaskIntoConstraints = false
        sliderHolderView.translatesAutoresizingMaskIntoConstraints = false
        frontTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        backTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        draggedView.translatesAutoresizingMaskIntoConstraints = false
        // Setup for view
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        // Setup for circle View
        leadingThumbnailViewConstraint = thumnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        leadingThumbnailViewConstraint?.isActive = true
        thumnailImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -3.0).isActive = true
        view.bottomAnchor.constraint(equalTo: thumnailImageView.bottomAnchor, constant: -3.0).isActive = true
        
        // Setup for slider holder view
        sliderHolderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sliderHolderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        view.bottomAnchor.constraint(equalTo: sliderHolderView.bottomAnchor, constant: 0.0).isActive = true
        sliderHolderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Setup for textLabel
        frontTitleLabel.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        sliderHolderView.bottomAnchor.constraint(equalTo: frontTitleLabel.bottomAnchor).isActive = true
        frontTitleLabel.centerXAnchor.constraint(equalTo: sliderHolderView.centerXAnchor).isActive = true
        frontTitleLabel.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor, constant: 0.0).isActive = true
        // Setup for sliderTextLabel
        backTitleLabel.topAnchor.constraint(equalTo: frontTitleLabel.topAnchor).isActive = true
        frontTitleLabel.bottomAnchor.constraint(equalTo: backTitleLabel.bottomAnchor).isActive = true
        backTitleLabel.leadingAnchor.constraint(equalTo: frontTitleLabel.leadingAnchor).isActive = true
        backTitleLabel.trailingAnchor.constraint(equalTo: frontTitleLabel.trailingAnchor).isActive = true
        // Setup for Dragged View
        draggedView.leadingAnchor.constraint(equalTo: sliderHolderView.leadingAnchor).isActive = true
        draggedView.topAnchor.constraint(equalTo: sliderHolderView.topAnchor).isActive = true
        sliderHolderView.bottomAnchor.constraint(equalTo: draggedView.bottomAnchor).isActive = true
        draggedView.trailingAnchor.constraint(equalTo: thumnailImageView.trailingAnchor,
                                                                              constant: 0.0).isActive = true
    }
    
    func setStyle() {
        frontTitleLabel.textAlignment = .center
        backTitleLabel.textAlignment = .center
        backTitleLabel.isHidden = !showSliderText
        draggedView.clipsToBounds = true
        draggedView.layer.masksToBounds = true
    }

    func updateThumbnailXPosition(_ xPos: CGFloat) {
        leadingThumbnailViewConstraint?.constant = xPos
        setNeedsLayout()
    }
    
    // MARK: UIPanGestureRecognizer
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished || !isEnabled {
            return
        }
        let translatedPoint = sender.translation(in: view).x
        switch sender.state {
        case .began:
            break
        case .changed:
            changedAction(translatedPoint)
        case .ended:
            endAction(translatedPoint)
        default:
            break
        }
    }
    
    func changedAction(_ translatedPoint: CGFloat) {
        if translatedPoint >= xEndingPoint {
            updateThumbnailXPosition(xEndingPoint)
            return
        }
        if translatedPoint <= 0.0 {
           if shouldDimFrontText { frontTitleLabel.alpha = 1 }
            updateThumbnailXPosition(0.0)
            return
        }
        updateThumbnailXPosition(translatedPoint)
        if shouldDimFrontText { frontTitleLabel.alpha = (xEndingPoint - translatedPoint) / xEndingPoint }
    }
    
    func endAction(_ translatedPoint: CGFloat) {
        if translatedPoint >= xEndingPoint {
            if shouldDimFrontText { frontTitleLabel.alpha = 0 }
            updateThumbnailXPosition(xEndingPoint)
            // Finish action
            isFinished = true
            delegate?.slideToActionDidFinish(self)
            return
        }
        if translatedPoint <= 0.0 {
            if shouldDimFrontText { frontTitleLabel.alpha = 1 }
            updateThumbnailXPosition(0.0)
            return
        }
        UIView.animate(withDuration: animationVelocity) {
            self.leadingThumbnailViewConstraint?.constant = 0.0
            if self.shouldDimFrontText { self.frontTitleLabel.alpha = 1 }
            self.layoutIfNeeded()
        }
    }
}
