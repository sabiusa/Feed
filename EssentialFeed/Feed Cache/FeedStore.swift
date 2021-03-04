//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/2/21.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion handle can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handle can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    )
    
    /// The completion handle can be invoked on any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
