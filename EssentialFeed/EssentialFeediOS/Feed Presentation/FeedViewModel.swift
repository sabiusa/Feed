//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Saba Khutsishvili on 3/16/21.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
