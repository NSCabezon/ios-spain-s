import SQLite

open class SQLiteOpenHelper {
    
    private let dbPath: String
    private let version: Int
    
    /// init a new Sql lite opener:
    /// - param dbPath: The database path, the path must include the databaseName
    /// - param version: the database version wanted, must be >= 1
    public init(name: String, version: Int) {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        self.dbPath = "\(path)/\(name)"
        
        guard version >= 1 else {
            fatalError("The version should be >= 1")
        }
        self.version = version
    }
    
    /// Get a connection to the database
    /// - param readOnly
    public func open(readOnly: Bool = false) -> Connection {
        do {
            
            let database = try Connection(dbPath, readonly: readOnly)
            
            try database.transaction {
                
                let oldVersion = database.version
                
                if oldVersion == 0 {
                    self.onCreate(database)
                } else if oldVersion != self.version {
                    self.onUpgrade(database, oldVersion, self.version)
                }
                
                database.version = self.version
            }
            
            return database
            
        } catch let error {
            fatalError("ERROR EN CONEXION!!! \(error)")
        }
        
    }
    
    /// called when the database is created
    /// this method should create the tables and populate the inital data
    /// the newVersion will be automatically set
    /// - param db: the database
    open func onCreate(_ database: Connection) {
        fatalError("This method should be overridden and add the new tables")
    }
    
    /// called when the database should be upgraded
    /// this method should create create or alter the tables or population
    /// the newVersion will be automatically set when the method finish
    /// - param db: the database
    /// - param oldVersion the old version of the database
    /// - param newVersion the new version of the database ( greater then old )
    public func onUpgrade(_ database: Connection, _ oldVersion: Int, _ newVersion: Int) {
        fatalError("This method should be overridden and upgrade")
    }
    
}
