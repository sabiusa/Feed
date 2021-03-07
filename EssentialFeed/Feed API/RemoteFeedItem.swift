//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Saba Khutsishvili on 3/2/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
