import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FitnessModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations for TrainingSession
    
    func createTrainingSession(date: Date, bodyPart: String, duration: Int) -> TrainingSession {
        let context = persistentContainer.viewContext
        let newSession = TrainingSession(context: context)
        newSession.id = UUID()
        newSession.date = date
        newSession.bodyPart = bodyPart
        newSession.duration = Int16(duration)
        
        do {
            try context.save()
            return newSession
        } catch {
            print("Failed to save context: \(error)")
            // 在实际应用中，你可能想要更好地处理这个错误
            fatalError("Failed to save context: \(error)")
        }
    }
    
    func fetchTrainingSessions() -> [TrainingSession] {
        let fetchRequest: NSFetchRequest<TrainingSession> = TrainingSession.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrainingSession.date, ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch training sessions: \(error)")
            return []
        }
    }
    
    func updateTrainingSession(_ session: TrainingSession) {
        saveContext()
    }
    
    func deleteTrainingSession(_ session: TrainingSession) {
        viewContext.delete(session)
        saveContext()
    }
    
    // MARK: - CRUD Operations for Exercise
    
    func addExercise(to session: TrainingSession, name: String) -> Exercise? {
        let context = persistentContainer.viewContext
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.session = session
        session.addToExercises(exercise)
        
        do {
            try context.save()
            return exercise
        } catch {
            print("Failed to save exercise: \(error)")
            context.rollback()
            return nil
        }
    }
    func deleteExercise(_ exercise: Exercise) {
        viewContext.delete(exercise)
        saveContext()
    }
    
    // MARK: - CRUD Operations for ExerciseSet
    
    func createExerciseSet(weight: Double, reps: Int, forExercise exercise: Exercise) -> ExerciseSet {
        let set = ExerciseSet(context: viewContext)
        set.id = UUID()
        set.weight = weight
        set.reps = Int16(reps)
        set.exercise = exercise
        
        saveContext()
        return set
    }
    
    func deleteExerciseSet(_ set: ExerciseSet) {
        viewContext.delete(set)
        saveContext()
    }
}
