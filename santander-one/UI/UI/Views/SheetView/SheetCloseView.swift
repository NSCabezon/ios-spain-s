//
//  SheetCloseView.swift
//  SheetView
//
//  Created by Juan Carlos López Robles on 4/1/20.
//  Copyright © 2020 Juan Carlos López Robles. All rights reserved.
//

import Foundation
import UIKit

final class SheetCloseView: UIView {
    private let dragIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        self.backgroundColor = .white
        self.addTopDragIdicator()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.roundCorners(corners: [.topLeft, .topRight], radius: 6)
    }
    
    func showDragIdicator() {
        self.dragIndicator.isHidden = false
    }
}

private extension SheetCloseView {
    
    func addTopDragIdicator() {
        self.dragIndicator.isHidden = true
        self.addSubview(self.dragIndicator)
        self.dragIndicator.drawBorder(cornerRadius: 2, color: .clear, width: 1)
        self.dragIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.dragIndicator.widthAnchor.constraint(equalToConstant: 27),
            self.dragIndicator.heightAnchor.constraint(equalToConstant: 4),
            self.dragIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.dragIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
