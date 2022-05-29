//
//  OTPCodeCollapsedView.swift
//  UI
//
//  Created by alvola on 24/06/2020.
//

import UIKit
import CoreFoundationLib

public final class OTPCodeCollapsedView: UIView {

    private lazy var arrowImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnArrowUpPendin"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension OTPCodeCollapsedView {
    func commonInit() {
        backgroundColor = .white
        arrowImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        arrowImage.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        arrowImage.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 21.0).isActive = true
    }
}

extension OTPCodeCollapsedView: StickyCollapsedViewProtocol {
    public func setInfo(_ info: Any) { }
}
