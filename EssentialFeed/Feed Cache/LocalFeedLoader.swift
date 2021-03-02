//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/2/21.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(
        store: FeedStore,
        currentDate: @escaping () -> Date
    ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(
        _ items: [FeedItem],
        with completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(
            items.toLocal(),
            timestamp: currentDate(),
            completion: { [weak self] insertionError in
                guard self != nil else { return }
                
                completion(insertionError)
            }
        )
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map {
            return LocalFeedItem(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                imageURL: $0.imageURL
           )
        }
    }
}
