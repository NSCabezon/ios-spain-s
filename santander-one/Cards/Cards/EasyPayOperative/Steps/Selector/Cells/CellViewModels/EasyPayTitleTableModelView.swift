//
//  EasyPayTitleTableModelView.swift
//  Cards
//
//  Created by alvola on 14/12/2020.
//

final class EasyPayTitleTableModelView {
    let date: String?
    let identifier: String = "EasyPayTitleTableViewCell"
    
    init(date: String?) {
        self.date = date
    }
}

extension EasyPayTitleTableModelView: EasyPayTableViewModelProtocol { }
