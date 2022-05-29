//
//  SideMenuTitleSectionViewModel.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 28/05/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation

class SideMenuTitleSectionViewModel: TableModelViewItem<MenuSectionTitleTableViewCell> {
    var title: String?
    weak var view: MenuSectionTitleTableViewCell?
    var accesibilityId: String?
    
    init(title: String?, viewModelPrivateComponent: PresentationComponent, accesibilityID: String? = "") {
        self.title = title
        self.accesibilityId = accesibilityID
        super.init(dependencies: viewModelPrivateComponent)
    }
    
    override func bind(viewCell: MenuSectionTitleTableViewCell) {
        viewCell.titleLabel.text = title
        viewCell.titleLabel.accessibilityIdentifier = accesibilityId
        self.view = viewCell
    }
}
