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
    
    private let calendar = Calendar(identifier: .gregorian)
    private let maxCacheAgeInDays = 7
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(
        store: FeedStore,
        currentDate: @escaping () -> Date
    ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private func isValid(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(
                byAdding: .day,
                value: maxCacheAgeInDays,
                to: timestamp
        ) else {
            return false
        }
        
        return currentDate() < maxCacheAge
    }
}
 
extension LocalFeedLoader {
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(
        _ feed: [FeedImage],
        with completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(
            feed.toLocal(),
            timestamp: currentDate(),
            completion: { [weak self] insertionError in
                guard self != nil else { return }
                
                completion(insertionError)
            }
        )
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where self.isValid(timestamp):
                completion(.success(feed.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !self.isValid(timestamp):
                self.store.deleteCachedFeed { _ in }
            case .found, .empty:
                break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map {
            return LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
           )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map {
            return FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
           )
        }
    }
}
