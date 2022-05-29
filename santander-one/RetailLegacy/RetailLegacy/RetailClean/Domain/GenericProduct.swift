import SANLegacyLibrary
import Foundation
import CoreDomain

class GenericProduct {
    
    private var visible: Bool = true
    private var positionInList: Int = -1
    
    init() {
    }
    
    var productIdentifier: String {
        fatalError()
    }
    
    /**
     * Devuelve el alias, que es la primera información visible del producto
     */
    func getAlias() -> String? {
        fatalError()
    }

    func getAliasUpperCase() -> String {
        return getAlias()?.uppercased().noDoubleWhitespaces() ?? ""
    }

    func getAliasCamelCase() -> String {
        return getAlias()?.camelCasedString ?? ""
    }
    
    func getAliasAndInfo(withCustomAlias alias: String? = nil) -> String {
        fatalError()
    }
    
    /**
     * Devuelve la segunda información visible del producto, que suele ser el IBAN / PAN / Contrato
     */
    func getDetailUI() -> String? {
        fatalError()
    }
    
    /**
     * Devuelve el importe visible del producto (sin divisa), que suele ser un saldo (cuentas), saldo dispuesto (tarjetas),
     * valoración (carteras)... Si no hay ningún importe a mostrar, se devuelve null (tarjetas de débito?)
     */
    func getAmountValue() -> Decimal? {
        fatalError()
    }
    
    func getAvailableAmountValue() -> Decimal? {
        fatalError()
    }
    
    /**
     * Devuelve la divisa visible del producto
     */
    func getAmountCurrency() -> CurrencyDTO? {
        fatalError()
    }
    
    /**
     * Devuelve el tipo de intervención sobre el producto, sólo para usuarios PB
     *
     * @return tipo de intervención: "TITULAR", "AUTORIZADO", etc.
     */
    func getTipoInterv() -> OwnershipTypeDesc? {
        fatalError()
    }
    
    func getCounterValueAmountValue() -> Decimal? {
        return nil
    }
    
    public func isVisible() -> Bool {
        return visible
    }
    
    func setVisible(_ visible: Bool) {
        self.visible = visible
    }
    
    func getPositionInList() -> Int {
        return positionInList
    }
    
    func setPositionInList(_ positionInList: Int) {
        self.positionInList = positionInList
    }
    
    func getAmount() -> Amount? {
        if let amount = getAmountValue(), let amountCurrency = getAmountCurrency() {
            return Amount.createFromDTO(AmountDTO(value: amount, currency: amountCurrency))
        }
        return nil
    }
    
    func getAmountUI() -> String {
        return getAmount()?.getFormattedAmountUIWith1M() ?? ""
    }
    
    func getLongAmountUI() -> String {
        return getAmount()?.getFormattedAmountUI() ?? ""
    }
    
    func transformToAliasAndInfo(alias: String) -> String {
        if alias.count <= 20 {
            return alias
        } else {
            return (alias.substring(0, 19) ?? "") + "..."
        }
    }
}
