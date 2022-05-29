import Foundation
import CoreFoundationLib
import UI
import CoreDomain

public protocol PublicMenuCoordinatorDelegate: AnyObject {
    func openUrl(_ url: String)
    func goToAtmLocator()
    func goToStockholders()
    func goToOurProducts()
    func toggleSideMenu()
    func goToHomeTips()
    func didSelectOffer(_ offer: OfferRepresentable?)
    func didSelectOfferNodrawer(_ offer: OfferEntity?)
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?)
}
