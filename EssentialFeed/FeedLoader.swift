//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 2/17/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
