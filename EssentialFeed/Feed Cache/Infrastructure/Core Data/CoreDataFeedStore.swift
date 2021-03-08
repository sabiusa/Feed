//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/8/21.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    
    public init() {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(
        _ feed: [LocalFeedImage],
        timestamp: Date,
        completion: @escaping InsertionCompletion
    ) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
