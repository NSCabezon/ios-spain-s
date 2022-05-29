import Foundation
import CoreFoundationLib
import Operative

public protocol TransferGenericAmountEntryPresenterProtocol: ValidatableFormPresenterProtocol {
    var dataEntryView: TransferGenericAmountEntryViewProtocol? { get set }
    func changeAccountSelected()
    func onContinueButtonClicked()
    func updateCountry(_ country: SepaCountryInfoEntity)
    func updateCurrency(_ currency: SepaCurrencyInfoEntity)
    func updateAmount(_ amount: String?)
    func updateConcept(_ concept: String?)
    func closeLocationBanner(_ offerId: String?)
    func selectLocationBanner()
}
