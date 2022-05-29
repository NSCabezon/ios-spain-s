//
//  OfferTableViewCell.swift
//  GlobalPosition
//
//  Created by alvola on 15/10/2019.
//

import UIKit
import UI
import CoreFoundationLib
import OfferCarousel

protocol PullOfferTableViewCellDelegate: AnyObject {
    func pullOfferCloseDidPressed(_ elem: Any?)
    func pullOfferResizeTo(_ size: CGFloat, _ elem: Any?)
}

protocol PullOfferCellProtocol: GeneralPGCellProtocol {
    func setCellDelegate(_ delegate: PullOfferTableViewCellDelegate?)
    func hideFrame(_ hide: Bool)
    func addMargintTop(_ margin: CGFloat)
}

final class OfferTableViewCell: UITableViewCell, PullOfferCellProtocol, RoundedCellProtocol {
    @IBOutlet weak var frameView: RoundedView?
    @IBOutlet weak var offerImage: UIImageView?
    @IBOutlet weak var closeImage: UIImageView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var topConstraint: NSLayoutConstraint?
    
    private var offer: Any?
    private var height: CGFloat = 81.0
    private var currentTask: CancelableTask?
    weak var delegate: PullOfferTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        offer = nil
        frameView?.layer.borderWidth = 0
        offerImage?.image = nil
        bottomConstraint?.constant = 1
        topConstraint?.constant = 0.0
        height = 81.0
        currentTask?.cancel()
    }
    
    func roundTopCorners() { }
    func roundBottomCorners() { bottomConstraint?.constant = 6.0; frameView?.roundBottomCorners(); setNeedsLayout() }
    func roundCorners() { }
    func removeCorners() { frameView?.removeCorners() }
    func onlySideFrame() { frameView?.onlySideFrame() }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? CarouselOfferViewModel, let image = info.imgURL else { return }
        offer = info.elem
        currentTask = offerImage?.loadImage(urlString: image) { [weak self] in
            if let image = self?.offerImage?.image {
                let aspectRation = image.size.height / image.size.width
                let size = ((self?.offerImage?.frame.width ?? 0.0) * aspectRation) + (self?.topConstraint?.constant ?? 0.0)

                if self?.height != size {
                    self?.delegate?.pullOfferResizeTo(size, self?.offer)
                }
            }
        }
        height = info.height ?? 81.0
        closeImage?.image = !info.transparentClosure ? Assets.image(named: "icnXPullofferCopy") : nil
    }
    
    func hideFrame(_ hide: Bool) {
        guard hide else {
            onlySideFrame()
            return
        }
        removeCorners()
        frameView?.backgroundColor = .clear
    }
    func addMargintTop(_ margin: CGFloat) { topConstraint?.constant = margin }
    func setCellDelegate(_ delegate: PullOfferTableViewCellDelegate?) { self.delegate = delegate }

    private func commonInit() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.skyGray
        offerImage?.clipsToBounds = true
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibility) 
    }
    
    private func setAccessibility() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = localized("voiceover_commercialOffer")
    }
    
    private func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.offerCell
        self.closeImage?.isAccessibilityElement = true
        self.offerImage?.isAccessibilityElement = true
        self.setAccessibility {
            self.closeImage?.isAccessibilityElement = false
            self.offerImage?.isAccessibilityElement = false
        }
        self.closeImage?.accessibilityIdentifier = AccessibilityGlobalPosition.offerCellCloseImage
        self.offerImage?.accessibilityIdentifier = AccessibilityGlobalPosition.offerCellImage
    }

    @IBAction private func closeDidPressed(_ sender: UIButton) {
        delegate?.pullOfferCloseDidPressed(offer)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: height + (bottomConstraint?.constant ?? 0.0))
    }
}

extension OfferTableViewCell: AccessibilityCapable { }
