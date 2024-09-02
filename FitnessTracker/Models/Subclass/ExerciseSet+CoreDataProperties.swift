//
//  ExerciseSet+CoreDataProperties.swift
//  FitnessTracker
//
//  Created by jf on 30/8/2024.
//
//

import Foundation
import CoreData


extension ExerciseSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseSet> {
        return NSFetchRequest<ExerciseSet>(entityName: "ExerciseSet")
    }

    @NSManaged public var id: UUID
    @NSManaged public var reps: Int32
    @NSManaged public var weight: Double
    @NSManaged public var exercise: Exercise?

}

extension ExerciseSet : Identifiable {

}
