//
//  RuntimeFeedStore.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/9/21.
//

import Foundation

public final class ConcurrentFeedStoreDecorator: FeedStore {
    
    private let decoratee: FeedStore
    private let queue = DispatchQueue(
        label: "\(ConcurrentFeedStoreDecorator.self)Queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    public init(store: FeedStore) {
        decoratee = store
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async { [decoratee] in
            decoratee.retrieve(completion: completion)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [decoratee] in
            decoratee.insert(feed, timestamp: timestamp, completion: completion)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [decoratee] in
            decoratee.deleteCachedFeed(completion: completion)
        }
    }
}

public final class RuntimeFeedStore: FeedStore {
    
    private struct Cache {
        let feed: [LocalFeedImage]
        let timestamp: Date
        
        init(feed: [LocalFeedImage], timestamp: Date) {
            self.feed = feed
            self.timestamp = timestamp
        }
    }
    
    private static var cache: Cache?
    
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let cache = RuntimeFeedStore.cache, !cache.feed.isEmpty else {
            return completion(.empty)
        }
        
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        RuntimeFeedStore.cache = Cache(feed: feed, timestamp: timestamp)
        completion(nil)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        RuntimeFeedStore.cache = nil
        completion(nil)
    }
}
