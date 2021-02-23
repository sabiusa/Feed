//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 2/17/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
