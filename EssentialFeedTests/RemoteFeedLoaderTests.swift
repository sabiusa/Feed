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
        sut.load { _ in }
        
        // Then | Assert
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        // Given | Arrange
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        // When | Act
        sut.load { _ in }
        sut.load { _ in }
        
        // Then | Assert
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let sampleCodes = [199, 201, 300, 444, 500, 666]
        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = "{\"items\": []}"
            let data = Data(emptyListJSON.utf8)
            client.complete(withStatusCode: 200, data: data)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-given-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://a-given-url.com")!
        )
        
        let itemModels = [item1.model, item2.model]        
        expect(sut, toCompleteWith: .success(itemModels), when: {
            let data = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data)
        })
    }
    
    // MARK:- Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> (),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { result in
            capturedResults.append(result)
        }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias Message = (url: URL, completion: (HTTPClientResult) -> Void)
        private var messages = [Message]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            withStatusCode code: Int,
            data: Data = Data(),
            at index: Int = 0
        ) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
