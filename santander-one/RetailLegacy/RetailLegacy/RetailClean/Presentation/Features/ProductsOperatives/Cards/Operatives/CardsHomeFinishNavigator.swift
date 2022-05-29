//
//  CardsHomeFinishNavigator.swift
//  RetailClean
//
//  Created by José Carlos Estela Anguita on 21/10/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Cards

final class CardsHomeFinishNavigator: StopOperativeProtocol {
    
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let destination = sourceView?.navigationController?.viewControllers.reversed().first(where: {
            $0 is CardsHomeViewController
        }) {
            sourceView?.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
