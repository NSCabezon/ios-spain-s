import SQLite
import Logger

public class DAOUserImage: DAOProtocol {
    static let tableName = "user_image"
    static let userIdField = "user_id"
    static let imageField = "image"
    static let lastUpdateField = "last_updated"
    
    private let dbm: DataBaseManager

    private var table: Table
    private var userId: Expression<String>
    private var image: Expression<Data>
    private var lastUpdate: Expression<Date>
    
    public required init(dbm: DataBaseManager) {
        self.dbm = dbm

        table = Table(DAOUserImage.tableName)
        userId = Expression<String>(DAOUserImage.userIdField)
        image = Expression<Data>(DAOUserImage.imageField)
        lastUpdate = Expression<Date>(DAOUserImage.lastUpdateField)
    }
    
    func createTable() -> String {
        return table.create(ifNotExists: true) { t in
            t.column(userId)
            t.column(image)
            t.column(lastUpdate)
            t.primaryKey(userId)
        }
    }
    
    public func image(forUserId userId: String) -> UIImage? {
        do {
            let rows = try dbm.prepare(selectQuery(userId: userId))
            let result = rows.map({ (row) -> UIImage? in
                return UIImage(data: row[self.image])
            })
            if let userImage = result.first {
                logTrace("Successfuly retrieved image for user #\(userId)")
                return userImage
            }
        } catch let error {
            logError(error)
        }
        
        //NO IMAGE RETRIEVED
        logWarning("Cannot retrieve image for user #\(userId). No previous image was saved.")
        return nil
    }
    
    public func save(image: UIImage, userId: String) {
        //UPSERT
        if self.image(forUserId: userId) != nil {
            if let query = updateQuery(image: image, userId: userId) {
                dbm.run(query)
                logTrace("Updating user image for user #\(userId)...")
            }
        } else {
            if let query = saveQuery(image: image, userId: userId) {
                dbm.run(query)
                logTrace("Saving user image for user #\(userId)...")
            }
        }
    }
    
    // MARK: - Private
    
    private func saveQuery(image: UIImage, userId: String) -> Insert? {
        guard let imageData = image.pngData() else {
            return nil
        }
        return table.insert(or: OnConflict.replace, self.userId <- userId, self.image <- imageData, lastUpdate <- Date())
    }
    
    private func updateQuery(image: UIImage, userId: String) -> Update? {
        guard let imageData = image.pngData() else {
            return nil
        }
        return table.update(self.userId <- userId, self.image <- imageData, lastUpdate <- Date())
    }
    
    private func selectQuery(userId: String) -> QueryType {
        return table.filter(self.userId == userId)
    }
}
