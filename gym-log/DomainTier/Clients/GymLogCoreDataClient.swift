//
//  GymLogCoreDataClient.swift
//  gym-log
//
//  Created by Brad Siegel on 1/15/20.
//  Copyright © 2020 Seagull LLC. All rights reserved.
//

import Foundation
import CoreData
import SPRingboard


internal protocol CoreDataClient: class {
    func fetchAllWorkouts() -> FutureResult<[Workout]>
    func fetchTodaysWorkout() -> FutureResult<[Workout]>
    func saveWorkout(workout: Workout) -> FutureResult<Bool>
    func toggleExerciseCompleted(exercise: Exercise, completed: Bool) -> FutureResult<Bool>
}

fileprivate let sharedCoreDataClient = CoreDataGymLogClient()

internal class CoreDataGymLogClient: CoreDataClient {
    
    public static let shared: CoreDataGymLogClient = sharedCoreDataClient
    
    internal func fetchAllWorkouts() -> FutureResult<[Workout]> {
        let deferred = DeferredResult<[Workout]>()
        
        let context = AppDelegate.viewContext
        let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        do {
            let workouts = try context.fetch(workoutRequest)
            NSLog("***** Successfully fetched all workouts: \(workouts.count)")
            deferred.success(value: workouts)
        } catch {
            NSLog("***** ERROR: fetchAllWorkouts() --> Failed to fetch all workouts")
            deferred.failure(
                error: GymLogError.databaseReadError(message: "Failed to fetch all workouts"))
        }
        return deferred
    }
    
    internal func fetchTodaysWorkout() -> FutureResult<[Workout]> {
        let deferred = DeferredResult<[Workout]>()
        
        let context = AppDelegate.viewContext
        context.perform {
            let workoutRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            workoutRequest.predicate = self.getDatePredicate()
            
            do {
                let workouts = try context.fetch(workoutRequest)
                NSLog("***** Successfully fetched today's workout: \(workouts.count)")
                deferred.success(value: workouts)
            } catch {
                NSLog("***** ERROR: fetchAllWorkouts() --> Failed to fetch today's workout")
                deferred.failure(
                    error: GymLogError.databaseReadError(message: "Failed to fetch today's workout"))
            }
        }
        return deferred
    }
    
    internal func saveWorkout(workout: Workout) -> FutureResult<Bool> {
        let deferred = DeferredResult<Bool>()
        return deferred
    }
    
    internal func toggleExerciseCompleted(exercise: Exercise, completed: Bool) -> FutureResult<Bool> {
        let deferred = DeferredResult<Bool>()
        let context = AppDelegate.viewContext
        context.perform {
            exercise.completed = completed
            do {
                try context.save()
                deferred.success(value: true)
            } catch {
                deferred.failure(error: GymLogError.updateError(message: "Unable to toggle completed for exercise"))
            }
        }
        return deferred
    }
    
    // Private functions
    
    /**
     *  Creates and returns an NSPredicate to query for a workout that is
     *  within today's date
     */
    private func getDatePredicate() -> NSPredicate {
        // Source: https://inneka.com/programming/swift/core-data-predicate-filter-by-todays-date/
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time

        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        
        return datePredicate
    }
}
