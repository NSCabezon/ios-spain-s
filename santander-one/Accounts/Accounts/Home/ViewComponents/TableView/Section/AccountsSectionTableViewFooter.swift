//
//  AccountsSectionTableViewFooter.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 12/12/2019.
//

import CoreFoundationLib

/// Return a footer with mediumSkyGray color, to be used on tableview footer, height will be determined by heightForFooterInSection tableView method
class AccountsSectionTableViewFooter: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.contentView.backgroundColor = UIColor.mediumSkyGray
    }
}
