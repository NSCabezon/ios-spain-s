import Foundation
import SQLite
import Logger

class DAODescription: DAOProtocol {
    static let tableName = "table_virtual_description"
    static let rowIdField = "docid"
    static let descriptionField = "transaction_description"
    
    private let dbm: DataBaseManager

    private var descriptionTable: VirtualTable
    private var descriptionRowId: Expression<Int>
    private var descriptionDescription: Expression<String>
    
    required init(dbm: DataBaseManager) {
        self.dbm = dbm

        descriptionTable = VirtualTable(DAODescription.tableName)
        descriptionRowId = Expression<Int>(DAODescription.rowIdField)
        descriptionDescription = Expression<String>(DAODescription.descriptionField)
    }
    
    func createTable() -> String {
        return descriptionTable.create(.FTS4(descriptionDescription), ifNotExists: true)
    }
    
    func insertDescription(description: DescriptionModel) {
        dbm.run(insertDescriptionQuery(description: description))
    }

    func description(rowId: Int, description: String) -> DescriptionModel? {
        do {
            let rows = try dbm.prepare(selectdescriptionQuery(rowId: rowId, description: description))
            let resutl = rows.map({ (row) -> DescriptionModel in
                let description = DescriptionModel(rowId: row[descriptionRowId], description: row[descriptionDescription])
                return description
            }).first
            return resutl
        } catch let error {
            logError(error)
        }
        return nil
    }

    // MARK: - Private

    private func insertDescriptionQuery(description: DescriptionModel) -> Insert {
        return descriptionTable.insert(or: OnConflict.ignore,
                descriptionRowId <- description.rowId,
                descriptionDescription <- description.description
        )
    }

    private func selectdescriptionQuery(rowId: Int, description: String) -> QueryType {
        return descriptionTable.filter(descriptionRowId == rowId && descriptionDescription == description)
    }
}
