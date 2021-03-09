//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Saba Khutsishvili on 3/7/21.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviousInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // MARK:- Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

extension CoreDataFeedStoreTests: FailableRetrieveFeedStoreSpecs {
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT()
        
        simulateFetchFailure()
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
        
        stopSimulatingFetchFailure()
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let sut = makeSUT()
        
        simulateFetchFailure()
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
        
        stopSimulatingFetchFailure()
    }
    
    private func simulateFetchFailure() {
        Swizzler.exchangeFetchImplementations()
    }
    
    private func stopSimulatingFetchFailure() {
        Swizzler.exchangeFetchImplementations()
    }
}

extension CoreDataFeedStoreTests: FailableInsertFeedStoreSpecs {
    
    func test_insert_deliversErrorOnInsertionError() {
        let sut = makeSUT()
        
        simulateSaveFailure()
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
        
        stopSimulatingSaveFailure()
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        
    }
    
    private func simulateSaveFailure() {
        Swizzler.exchangeSaveImplementations()
    }
    
    private func stopSimulatingSaveFailure() {
        Swizzler.exchangeSaveImplementations()
    }
}

private extension CoreDataFeedStoreTests {
    
    class Swizzler {
        
        static func exchangeFetchImplementations() {
            exchangeImplementations(
                of: NSManagedObjectContext.self, method1: #selector(NSManagedObjectContext.fetch),
                to: Swizzler.self, method2: #selector(fetch)
            )
        }
        
        static func exchangeSaveImplementations() {
            exchangeImplementations(
                of: NSManagedObjectContext.self, method1: #selector(NSManagedObjectContext.save),
                to: Swizzler.self, method2: #selector(save)
            )
        }
        
        private static func exchangeImplementations(
            of class1: AnyClass, method1: Selector,
            to class2: AnyClass, method2: Selector
        ) {
            let originalMethod = class_getInstanceMethod(class1, method1)
            let swizzledMethod = class_getInstanceMethod(class2, method2)
            
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        
        @objc
        private func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
            throw anyNSError()
        }
        
        @objc
        private func save() throws {
            throw anyNSError()
        }
        
        private func anyNSError() -> NSError {
            return NSError(domain: "any error", code: 0)
        }
    }
}
