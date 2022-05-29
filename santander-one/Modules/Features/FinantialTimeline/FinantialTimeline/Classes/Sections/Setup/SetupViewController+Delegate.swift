//
//  SetupViewController+Delegate.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 18/11/2019.
//

import Foundation

extension SetupViewController: MovementTypeFilterProtocol {
    func onUpdatedConstraint(_ height: CGFloat) {
        self.movementsFilterheight.constant = height
    }
    
    func onUpdated(_ list: [TimeLineConfiguration.Text]) {
        presenter?.updateBlackList(accountList: nil, cardList: nil, eventTypeList: list, maxDate: nil, minDate: nil, onlyFuture: nil)
    }
}

extension SetupViewController: DateFilterDelegate {
    func didUpdateValues(minimum: Float, maximum: Float, onlyFuture: Bool) {
        presenter?.updateBlackList(accountList: nil, cardList: nil, eventTypeList: nil, maxDate: Int(maximum), minDate: Int(minimum), onlyFuture: onlyFuture)
    }
}

extension SetupViewController: ProductFilterViewDelegate {
    func onUpdatedConstraint(_ height: CGFloat, with title: String) {
        switch title {
        case SetupString().accounts:
            self.accountsFilterHeight.constant = height
        case SetupString().cards:
            self.cardsFilterHeight.constant = height
        default:
            break
        }
        
    }
    
    func onUpdated(_ list: [Product], with title: String) {
        switch title {
        case SetupString().accounts:
            presenter?.updateBlackList(accountList: list, cardList: nil, eventTypeList: nil, maxDate: nil, minDate: nil, onlyFuture: nil)
        case SetupString().cards:
            presenter?.updateBlackList(accountList: nil, cardList: list, eventTypeList: nil, maxDate: nil, minDate: nil, onlyFuture: nil)
        default:
            break
        }
    }
}
