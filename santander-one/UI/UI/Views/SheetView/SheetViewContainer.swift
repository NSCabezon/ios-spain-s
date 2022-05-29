//
//  SheetViewContainer.swift
//  SheetView
//
//  Created by Juan Carlos López Robles on 4/1/20.
//  Copyright © 2020 Juan Carlos López Robles. All rights reserved.
//

import Foundation
import UIKit
import CoreFoundationLib

final class SheetViewContainer: UIView, TopWindowViewProtocol {
    private var closeView = SheetCloseView()
    private let closeImage = UIImageView(image: Assets.image(named: "icnCloseGray"))
    var contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    private func setup() {
        self.addSubview(closeView)
        self.addSubview(contentView)
        self.closeView.fitOnTopWithHeight(28, andTopSpace: 2)
        self.contentView.fitBelowView(closeView)
        self.contentView.backgroundColor = .white
        self.backgroundColor = .clear
        self.addCloseImage()
        self.setAccessibilityIdentifiers()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addTopShadow()
    }
    
    func addGesture(_ gesture: UIGestureRecognizer) {
        self.closeImage.addGestureRecognizer(gesture)
        self.closeImage.isUserInteractionEnabled = true
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.closeView.backgroundColor = color
        self.contentView.backgroundColor = color
    }
    
    func showDragIdicator() {
        self.closeView.showDragIdicator()
    }
    
    func getCloseView() -> SheetCloseView {
        self.closeView
    }
}

private extension SheetViewContainer {
    func addTopShadow() {
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 6
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    func addCloseImage() {
        self.addSubview(closeImage)
        self.addCloseImageConstraints()
    }
    
    func addCloseImageConstraints() {
        self.closeImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeImage.widthAnchor.constraint(equalToConstant: 24),
            closeImage.heightAnchor.constraint(equalToConstant: 24),
            closeImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 14),
            closeImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -19)
        ])
    }
    
    private func setAccessibilityIdentifiers() {
        self.closeView.accessibilityIdentifier = AccesibilitySheetViewContainer.sheetDialogCancelImageview
    }
}
