

public protocol AccountDescriptorRepositoryProtocol {
    func getAccountDescriptor() -> AccountDescriptorArrayDTO?
}

extension AccountDescriptorRepository: AccountDescriptorRepositoryProtocol {
    public func getAccountDescriptor() -> AccountDescriptorArrayDTO? {
        return self.get()
    }
}
