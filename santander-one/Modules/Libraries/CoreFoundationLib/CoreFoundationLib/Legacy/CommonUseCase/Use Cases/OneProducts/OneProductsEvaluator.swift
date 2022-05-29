import SANLegacyLibrary

public protocol OneProductsEvaluator {
    func hasOneProducts(
        accountDescriptorRepository: AccountDescriptorRepositoryProtocol,
        bsanManagersProvider: BSANManagersProvider,
        for keypath: KeyPath<AccountDescriptorArrayDTO, [ProductRangeDescriptorDTO]>
    ) -> Bool
}

public extension OneProductsEvaluator {
    func hasOneProducts(
        accountDescriptorRepository: AccountDescriptorRepositoryProtocol,
        bsanManagersProvider: BSANManagersProvider,
        for keypath: KeyPath<AccountDescriptorArrayDTO, [ProductRangeDescriptorDTO]>
    ) -> Bool {
        guard
            let products = accountDescriptorRepository.getAccountDescriptor()?[keyPath: keypath],
            let list = getCustomerContractList(bsanManagersProvider: bsanManagersProvider, loadedProducts: products)
            else { return false }
        let entities = products.map(ProductRangeDescriptorEntity.init)
        let hasOneProduct = entities.contains(where: { entity in
            return list.customerContractListDto.contains { (customerContract) -> Bool in
                guard
                    let productType = Int(customerContract.productType),
                    let productSubtype = Int(customerContract.productSubtype)
                    else { return false }
                return entity.isInRange(productType: productType, productSubtype: productSubtype)
            }
        })
        return hasOneProduct
    }
    
    private func getCustomerContractList(bsanManagersProvider: BSANManagersProvider, loadedProducts: [ProductRangeDescriptorDTO]) -> CustomerContractListDTO? {
        let rangesDto: [ProductOneRangeDTO] = loadedProducts.compactMap({ dto in
            guard
                let type = Int(dto.type ?? ""),
                let fromSubtype = Int(dto.fromSubtype ?? ""),
                let toSubtype = Int(dto.toSubtype ?? "")
                else { return nil }
            return ProductOneRangeDTO(type: type, subtypeFrom: fromSubtype, subtypeTo: toSubtype)
        })
        guard !rangesDto.isEmpty else { return nil }
        let customerContractListResponse = try? bsanManagersProvider.getBsanOnePlanManager().checkOnePlan(ranges: rangesDto)
        guard
            customerContractListResponse?.isSuccess() == true,
            let dto = try? customerContractListResponse?.getResponseData()
            else { return nil }
        return dto
    }
}
