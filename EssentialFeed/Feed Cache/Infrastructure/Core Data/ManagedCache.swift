//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/8/21.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}
