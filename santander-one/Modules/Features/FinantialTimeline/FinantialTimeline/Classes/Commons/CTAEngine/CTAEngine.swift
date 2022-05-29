//
//  CTAEngine.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 04/09/2019.
//

import Foundation

class CTAEngine {
    
    private let locale: Locale
    private var texts: [TimeLineConfiguration.Text] = []
    private var CTAs: [String: CTAStructure] = [:]
    
    init(locale: Locale) {
        self.locale = locale
    }
    
    func setupCTAs(_ texts: [TimeLineConfiguration.Text], CTAs: [String: CTAStructure]) {
        self.texts = texts
        self.CTAs = CTAs
    }
    
    
    func getCTAs(for type: String) -> [CTAAction]? {
        if let item = texts.first(where: { $0.transactionType == type }),
            let CTAArrayString = item.CTA {
                return getCTAStructureArray(for: CTAArrayString)
        } else {
            return nil
        }
    }
    
    func getCTAStructureArray(for ctas: [String]) -> [CTAAction]? {
        
        // ArrayOfActionsToCheck
        var actionsToCheck: [String: CTAStructure] = [:]
        
        // Add actions passed by integrator
        if let integratorActions = TimeLine.dependencies.configuration?.native?.actions {
            integratorActions.forEach { publicCTA in
                CTAs.forEach {
                    if $0.value.action.delegateReference == publicCTA.reference {
                        actionsToCheck.updateValue($0.value, forKey: $0.key)
                    }
                }
            }
        }
        
        // Add actions without delegateReference
        let componentActions = CTAs.filter { $0.value.action.delegateReference == nil }
        componentActions.forEach { actionsToCheck.updateValue($0.value, forKey: $0.key) }
                    
        // Filter array of actions with ctas in the method argument
        var arrayToReturn: [CTAAction] = []
        ctas.forEach { ctaIdentifier in
            actionsToCheck.forEach {
                if $0.key == ctaIdentifier {
                    let action = CTAAction(identifier: ctaIdentifier)
                    action.structure = $0.value
                    arrayToReturn.append(action)
                }
            }
        }
        return arrayToReturn.count == 0 ? nil : arrayToReturn
    }
}

extension CTAEngine: TimeLineDelegate {
     func onTimeLineCTATap(from viewController: TimeLineDetailViewController, with action: CTAAction) {
        guard let type = action.structure?.action.type else { return }
        switch type {
        case "SHARE":
            CTAEngine.share(action, from: viewController)
        case "REMINDER":
            CTAEngine.remindMeAction(action, from: viewController)
        case "DELETE_CUSTOM_EVENT":
            CTAEngine.deleteEvent(action, from: viewController)
        case "EDIT_CUSTOM_EVENT":
            CTAEngine.modify(action, from: viewController)
        default:
            break
        }
    }
}

extension CTAEngine {
    class func share(_ action: CTAAction, from controller: UIViewController) {
        guard let event = action.event,
        let shareEventTextFormat = action.structure?.action.composedDescription?.getShareFormat() else { return }
        
        let eventName = event.transaction.description ?? ""
        let date = event.date.string(format: .ddMMyyyy)
        var amountStr = ""
        if let amount = event.amount {
            let attr = NSAttributedString(amount, isPast: true ,color: .greyishBrown, integerFont: .santanderText(type: .boldItalic, with: 36), fractionFont: .santanderText(type: .boldItalic, with: 27))
            amountStr = attr.string
        }
        
        let shareStr = String(format: shareEventTextFormat, eventName, date, amountStr)
        
        let textToShare = [ shareStr ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view
        
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
    class func remindMeAction(_ action: CTAAction, from viewController: UIViewController) {
        
        guard let viewController = viewController as? TimeLineDetailViewController else { return }
        
        if viewController.presenter?.getDetail()?.deferredDetails?.alertType != nil {
            viewController.presenter?.deleteAlert()
        } else {
            viewController.presenter?.createAlert()
        }
    }
    
    class func deleteEvent(_ action: CTAAction, from viewController: UIViewController) {        
        guard let viewController = viewController as? TimeLineDetailViewController else { return }
        viewController.presenter?.deleteEvent()
    }
    
    class func modify(_ action: CTAAction, from viewController: UIViewController) {
        if let viewController = viewController as? TimeLineDetailViewController {
            if let presenter = viewController.presenter {
                if let detail = presenter.getDetail() {
                    guard let periodicEventCode = detail.deferredDetails?.periodicEventId else { return }
                    viewController.presenter?.getMasterPersonalEvent(code: periodicEventCode)
                }
                if let periodicEvent = presenter.getPeriodicEvent() {
                    guard let periodicEventCode = periodicEvent.id else { return }
                    viewController.presenter?.getMasterPersonalEvent(code: periodicEventCode)
                }
            }

        }
    }
}
