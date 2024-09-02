//
//  TrainingSession+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by jf on 30/8/2024.
//
//

import Foundation
import CoreData


extension TrainingSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingSession> {
        return NSFetchRequest<TrainingSession>(entityName: "TrainingSession")
    }

    @NSManaged public var bodyPart: String
    @NSManaged public var date: Date
    @NSManaged public var duration: Int32
    @NSManaged public var id: UUID
    @NSManaged public var startTime: Date?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension TrainingSession {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension TrainingSession : Identifiable {

}
