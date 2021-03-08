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
                if let cache = try ManagedCache.fetch(in: context) {
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
            let cache = ManagedCache(context: context)
            cache.timestamp = timestamp
            
            let images: [ManagedFeedImage] = feed.map {
                let image = ManagedFeedImage(context: context)
                image.id = $0.id
                image.imageDescription = $0.description
                image.location = $0.location
                image.url = $0.url
                return image
            }
            
            cache.feed = NSOrderedSet(array: images)
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
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
