//
//  RuntimeFeedStore.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/9/21.
//

import Foundation

public class RuntimeFeedStore: FeedStore {
    
    private struct Cache {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    private var cache: Cache?
    private let queue = DispatchQueue(label: "\(RuntimeFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async { [self] in
            guard let cache = cache, !cache.feed.isEmpty else {
                return completion(.empty)
            }
            
            completion(.found(feed: cache.feed, timestamp: cache.timestamp))
        }
    }
    
    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        queue.async(flags: .barrier) { [self] in
            cache = Cache(feed: feed, timestamp: timestamp)
            completion(nil)
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [self] in
            cache = nil
            completion(nil)
        }
    }
}
