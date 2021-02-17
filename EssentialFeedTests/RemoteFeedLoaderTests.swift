//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Saba Khutsishvili on 2/17/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
                
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        // Given | Arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When | Act
        sut.load()
        
        // Then | Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // Given | Arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When | Act
        sut.load()
        sut.load()
        
        // Then | Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0, userInfo: nil)
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK:- Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
