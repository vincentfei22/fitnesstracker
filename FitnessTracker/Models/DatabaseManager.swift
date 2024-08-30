import Foundation
import GRDB

struct DatabaseManager {
    private let dbQueue: DatabaseQueue

    init() throws {
        let fileManager = FileManager.default
        let folderURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dbURL = folderURL.appendingPathComponent("fitnessTracker.sqlite")
        dbQueue = try DatabaseQueue(path: dbURL.path)
        
        try migrator.migrate(dbQueue)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createTables") { db in
            try db.create(table: "trainingSessions") { t in
                t.column("id", .text).primaryKey()
                t.column("date", .datetime).notNull()
                t.column("bodyPart", .text).notNull()
                t.column("duration", .integer).notNull()
                t.column("startTime", .datetime)
            }
            
            try db.create(table: "exercises") { t in
                t.column("id", .text).primaryKey()
                t.column("sessionId", .text).notNull().references("trainingSessions", onDelete: .cascade)
                t.column("name", .text).notNull()
            }
            
            try db.create(table: "exerciseSets") { t in
                t.column("id", .text).primaryKey()
                t.column("exerciseId", .text).notNull().references("exercises", onDelete: .cascade)
                t.column("weight", .double).notNull()
                t.column("reps", .integer).notNull()
            }
        }
        
        return migrator
    }
}

// MARK: - Record types

extension TrainingSession: FetchableRecord, PersistableRecord {
    static let exercises = hasMany(Exercise.self)
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let date = Column(CodingKeys.date)
        static let bodyPart = Column(CodingKeys.bodyPart)
        static let duration = Column(CodingKeys.duration)
        static let startTime = Column(CodingKeys.startTime)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}

extension Exercise: FetchableRecord, PersistableRecord {
    static let session = belongsTo(TrainingSession.self)
    static let sets = hasMany(ExerciseSet.self)
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let sessionId = Column("sessionId")
        static let name = Column(CodingKeys.name)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}

extension ExerciseSet: FetchableRecord, PersistableRecord {
    static let exercise = belongsTo(Exercise.self)
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let exerciseId = Column("exerciseId")
        static let weight = Column(CodingKeys.weight)
        static let reps = Column(CodingKeys.reps)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Implementation not needed as we're using UUID
    }
}
