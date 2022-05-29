//
//  ToRetirementPlanHomeNavigator.swift
//  RetailLegacy
//
//  Created by Daniel Gómez Barroso on 17/8/21.
//

import Transfer

final class ToRetirementPlanHomeNavigator: StopOperativeProtocol {
    func onSuccess(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        guard let viewControllers = sourceView?.navigationController?.viewControllers,
              let retirementHomeViewController = viewControllers.last(where: { $0 is ProductHomeViewController }) else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
            return
        }
        sourceView?.navigationController?.popToViewController(retirementHomeViewController, animated: true)
    }
}
