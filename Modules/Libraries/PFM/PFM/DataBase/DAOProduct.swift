import Foundation
import SQLite
import Logger

public class DAOProduct: DAOProtocol {
    static let tableName = "table_product"
    static let productIdField = "product_id"
    static let productUserIdField = "product_user_id"
    static let productTypeField = "product_type"
    static let productLastUpdateField = "product_last_updated"
    static let productRevisionField = "product_revision"

    
    private let dbm: DataBaseManager
    
    private var productTable: Table
    private var productId: Expression<String>
    private var productUserId: Expression<String>
    private var productType: Expression<String>
    private var productLastUpdate: Expression<Date>
    private var productRevision: Expression<Int>
    
    public required init(dbm: DataBaseManager) {
        self.dbm = dbm
        
        productTable = Table(DAOProduct.tableName)
        productId = Expression<String>(DAOProduct.productIdField)
        productUserId = Expression<String>(DAOProduct.productUserIdField)
        productType = Expression<String>(DAOProduct.productTypeField)
        productLastUpdate = Expression<Date>(DAOProduct.productLastUpdateField)
        productRevision = Expression<Int>(DAOProduct.productRevisionField)
    }
    
    func createTable() -> String {
        return productTable.create(ifNotExists: true) { t in
            t.column(productId)
            t.column(productUserId)
            t.column(productType)
            t.column(productLastUpdate)
            t.column(productRevision)
            t.primaryKey(productId, productUserId)
        }
    }
    
    public func insertProduct(product: ProductModel) {
        dbm.run(insertProductQuery(product: product))
    }
    
    public func insertProduct(products: [ProductModel]) {
        for product in products {
            dbm.run(insertProductQuery(product: product))
        }
    }
    
    func alterTableAddRevisionColumn() -> String {
        return productTable.addColumn(Expression<Int?>(productRevision), defaultValue: 0)
    }
    
    public func products(type: String) -> [ProductModel]? {
        do {
            let rows = try dbm.prepare(selectProductQuery(type: type))
            let resutl = rows.map({ (row) -> ProductModel in
                let product = ProductModel(userId: row[productUserId],
                                           id: row[productId],
                                           type: row[productType],
                                           lastUpdate: row[productLastUpdate],
                                           revision:0)
                return product
            })
            return resutl
        } catch let error {
            logError(error)
        }
        return nil
    }
    
    public func product(id: String, userId: String) -> ProductModel? {
        do {
            let rows = try dbm.prepare(selectProductQuery(id: id, userId: userId))
            let resutl = rows.map({ (row) -> ProductModel in
                let product = ProductModel(userId: row[productUserId],
                                           id: row[productId],
                                           type: row[productType],
                                           lastUpdate: row[productLastUpdate],
                                           revision:0)
                return product
            }).first
            return resutl
        } catch let error {
            logError(error)
        }
        return nil
    }
    
    public func updateProduct(product: ProductModel) {
        let productToUpdate = selectProductQuery(id: product.id, userId: product.userId)
        
        dbm.run(productToUpdate.update([productLastUpdate <- product.lastUpdate]))
    }
    
    public func updateLastDateProduct(id: String, userId: String) {
        let productToUpdate = selectProductQuery(id: id, userId:userId)

        dbm.run(productToUpdate.update([productLastUpdate <- Date()]))
    }
    
    public func deleteProduct(product: ProductModel) {
        let productToUpdate = selectProductQuery(id: product.id, userId: product.userId)
        
        dbm.run(productToUpdate.delete())
    }
    
    func updateRevisionProduct(product: ProductModel) {
        let productToRevision = selectProductQuery(id: product.id, userId: product.userId)
        dbm.run(productToRevision.update([productRevision <- product.revision]))
    }
    
    // MARK: - Private
    
    private func insertProductQuery(product: ProductModel) -> Insert {
        return productTable.insert(or: OnConflict.ignore, productId <- product.id, productUserId <- product.userId, productType <- product.type, productLastUpdate <- product.lastUpdate, productRevision <- product.revision)
    }
    
    private func selectProductQuery(id: String, userId: String) -> QueryType {
        return productTable.filter(productId == id && productUserId == userId)
    }
    
    private func selectProductQuery(type: String) -> QueryType {
        return productTable.filter(productType == type)
    }
}
