//
//  FavouriteContactsSearchBarView.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 24/1/22.
//

import CoreFoundationLib
import UIOneComponents
import UIKit
import UI

final class FavouriteContactsSearchBarView: XibView {
    @IBOutlet private weak var searchBar: OneInputRegularView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

private extension FavouriteContactsSearchBarView {
    func setupView() {
        let viewModel = OneInputRegularViewModel(status: .inactive,
                                                 placeholder: localized("favoriteRecipient_label_searchByFavourites"),
                                                 searchAction: didSelectSearch)
        searchBar.setupTextField(viewModel)
        setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        searchBar.accessibilityIdentifier = AccessibilityOneFavouritesList.favouriteContactSearchBarView
    }
    
    func didSelectSearch() {
        
    }
}
