//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/8/21.
//

import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(
            modelName: "FeedStore",
            storeURL: storeURL,
            in: bundle
        )
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        context.perform { [context] in
            do {
                let cache = try ManagedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedFeedImage.cacheFeed(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform { [context] in
            do {
                try ManagedCache.find(in: context).map(context.delete)
                try context.save()
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
}

/// Subclass of `NSPersistentContainer` can use simpler `init` API
/// as it looks for the type's bundle to look for the `NSManagedObjectModel`
/// CoreData best practises - https://developer.apple.com/videos/play/wwdc2018/224/
private class FeedStorePersistentContainer: NSPersistentContainer {
    
    enum LoadError: Error {
        case storesFailedToLoaded(Error)
    }
    
    static func load(
        modelName: String,
        storeURL: URL
    ) throws -> FeedStorePersistentContainer {
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = FeedStorePersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { desc, error in
            loadError = error
        }
        if let error = loadError {
            throw LoadError.storesFailedToLoaded(error)
        }
        
        return container
    }
}

private extension NSPersistentContainer {
    
    enum LoadError: Error {
        case modelNotFound
        case storesFailedToLoaded(Error)
    }
    
    static func load(
        modelName: String,
        storeURL: URL,
        in bundle: Bundle
    ) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.load(named: modelName, in: bundle) else {
            throw LoadError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { desc, error in
            loadError = error
        }
        if let error = loadError {
            throw LoadError.storesFailedToLoaded(error)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    
    static func load(named name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
