//
//  SLMockServicesTests.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 16/03/2025.
//

import XCTest
@testable import SL_RepoCoreData
@testable import SL_NetworkModule
@testable import SLRepoListingTest


// MARK: - Mock CoreDataService
class MockCoreDataService: CoreDataService {
    var storedCommits: [[String: Any]] = []
    
    override func fetchCommits(for repoID: String) -> [[String: Any]] {
        return storedCommits
    }
    
    override func saveCommits(_ commits: [[String: Any]], for repoID: String) {
        storedCommits = commits
    }
}

// MARK: - Mock NetworkService
class MockNetworkService: NetworkService {
    var shouldReturnError = false
    var mockCommits: [Commit] = [
        Commit(sha: "123", message: "Mock Commit 1"),
        Commit(sha: "456", message: "Mock Commit 2")
    ]
    
    override func request<T>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 500, userInfo: nil)))
        } else {
            completion(.success(mockCommits as! T)) // Force cast to T (only safe in test)
        }
    }
}

