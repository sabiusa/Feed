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
    
    var localFeed: [LocalFeedImage] {
        return feed
            .compactMap { $0 as? ManagedFeedImage }
            .map { $0.localImage }
    }
}

extension ManagedCache {
    
    enum Error: Swift.Error {
        case missingEntityName
    }
    
    static func fetch(in context: NSManagedObjectContext) throws -> ManagedCache? {
        guard let name = ManagedCache.entity().name else {
            throw Error.missingEntityName
        }
        
        let request = NSFetchRequest<ManagedCache>(entityName: name)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(
        in context: NSManagedObjectContext
    ) throws -> ManagedCache {
        try fetch(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
