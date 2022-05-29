//
//  FavouriteContactsFooter.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 20/1/22.
//

import Foundation
import UIKit
import UI

final class FavouriteContactsFooter: UICollectionReusableView {
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
     }
}

private extension FavouriteContactsFooter {
    func configure() {
        containerView.fullFit()
    }
}
