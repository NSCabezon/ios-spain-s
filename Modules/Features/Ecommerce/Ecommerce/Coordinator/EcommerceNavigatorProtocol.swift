public protocol EcommerceNavigatorProtocol {
    func showEcommerce(_ origin: EcommerceModuleCoordinator.EcommerceSection)
    func showEcommerce(_ origin: EcommerceModuleCoordinator.EcommerceSection, withCode lastPurchaseCode: String?)
}
