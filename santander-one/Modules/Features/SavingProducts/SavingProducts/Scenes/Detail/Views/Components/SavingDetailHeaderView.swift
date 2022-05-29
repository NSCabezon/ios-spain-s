//
//  SavingDetailHeaderView.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 26/4/22.
//

import UI
import UIKit
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import OpenCombine

final class SavingDetailHeaderView: UIView {
    private enum Constants {
        static let defaultHeight: CGFloat = 180
        static let additionalHeight: CGFloat = 40
    }
    let gradientView = OneGradientView()
    private var anySubscriptions = Set<AnyCancellable>()
    private var currentUpdatedHeight: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint?
    var savingProduct: Savings?
    var collectionView = SavingsHomeCollectionView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func updateHeight(_ heightToUpdate: CGFloat) {
        self.currentUpdatedHeight = heightToUpdate
        adaptViewHeight(Constants.defaultHeight + currentUpdatedHeight)
    }

    func setInitialHeight() {
        heightConstraint = self.heightAnchor.constraint(equalToConstant: Constants.defaultHeight)
        heightConstraint?.isActive = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        adaptViewHeight(currentUpdatedHeight + Constants.defaultHeight)
    }
}

private extension SavingDetailHeaderView {

    func setupView() {
        self.backgroundColor = .oneWhite
        self.collectionView.backgroundColor = .clear
        self.addSubviews()
        self.configureSubviews()
        self.addConstraints()
    }

    func addSubviews() {
        self.addSubview(gradientView)
        self.addSubview(collectionView)
    }

    func configureSubviews() {
        gradientView.setupType(.oneGrayGradient(direction: GradientDirection.bottomToTop))
    }

    func addConstraints() {
        gradientView.fullFit()
        collectionView.fullFit(topMargin: 12, bottomMargin: 20, leftMargin: 24, rightMargin: 24)
    }

    func adaptViewHeight(_ height: CGFloat) {
        let adjustedHeight: CGFloat
        if #available(iOS 11.0, *) {
            adjustedHeight = UIFontMetrics.default.scaledValue(for: height)
        } else {
            adjustedHeight = (UIFont.preferredFont(forTextStyle: .body).pointSize / 17.0) * height
        }
        let newHeight = max(height, adjustedHeight)
        heightConstraint?.constant = newHeight + Constants.additionalHeight
        self.collectionView.updateCellHeight(newHeight)
        self.collectionView.layoutIfNeeded()
        self.updateConstraints()
    }
}
