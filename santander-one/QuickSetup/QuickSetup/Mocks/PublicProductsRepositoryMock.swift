import Foundation
import CoreFoundationLib

public final class PublicProductsRepositoryMock: PublicProductsRepositoryProtocol {
    public func getPublicProducts() -> PublicProductsDTO? {
        return nil
    }
    
    public func loadProduct(baseUrl: String, publicLanguage: PublicLanguage) { }
}
