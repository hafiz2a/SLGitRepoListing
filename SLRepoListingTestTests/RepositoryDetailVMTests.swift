//
//  RepositoryDetailVMTests.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 16/03/2025.
//
import XCTest
@testable import SLRepoListingTest


class RepositoryDetailVMTests: XCTestCase {
    
    var viewModel: RepositoryDetailVM!
    var mockCoreData: MockCoreDataService!
    var mockNetwork: MockNetworkService!
    var repository: Repository!

    override func setUp() {
        super.setUp()
        
        // Create mock services
        mockCoreData = MockCoreDataService(context: ConfiguareCoreData.shared.context)
        mockNetwork = MockNetworkService(authToken: "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")
        
        // Create a sample repository
        repository = Repository(id: 1 , name: "TestReport", description: "Test Description", html_url: "")

        // Initialize ViewModel with mocks
        viewModel = RepositoryDetailVM(repository: repository, coreDataService: mockCoreData, networkService: mockNetwork, commitMessages: [])
    }

    override func tearDown() {
        viewModel = nil
        mockCoreData = nil
        mockNetwork = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    func testFetchStoredCommits_WhenCommitsExist() {
        // Given stored commits in Core Data
        mockCoreData.storedCommits = [["sha": "abc123", "message": "Stored Commit"]]

        // When fetching commits
        viewModel.fetchCommits()

        // Then it should load stored commits
        XCTAssertEqual(viewModel.commitMessages.count, 1)
        XCTAssertEqual(viewModel.commitMessages.first?.message, "Stored Commit")
    }

    func testFetchStoredCommits_WhenNoCommitsExist() {
        // Given no stored commits
        mockCoreData.storedCommits = []

        // When fetching commits
        viewModel.fetchCommits()

        // Then it should create 3 dummy commits
        XCTAssertEqual(viewModel.commitMessages.count, 3)
        XCTAssertEqual(viewModel.commitMessages.first?.message, "Commit 0")
    }

    func testFetchCommitsFromAPI_Success() {
        // Given API returns commits
        mockNetwork.shouldReturnError = false

        let expectation = self.expectation(description: "Commits fetched from API")

        // When fetching commits from API
        viewModel.fetchCommitFromAPI {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)

        // Then it should load commits
        XCTAssertEqual(viewModel.commitMessages.count, 2)
        XCTAssertEqual(viewModel.commitMessages.first?.message, "Mock Commit 1")
    }



    func testSaveCommitsToCoreData() {
        // Given commits to save
        let commitsToSave = [
            Commit(sha: "123", message: "Saved Commit 1"),
            Commit(sha: "456", message: "Saved Commit 2")
        ]

        // When saving commits
        viewModel.saveCommitsToCoreData(commits: commitsToSave, repositoryID: "TestRepo")

        // Then they should be in Core Data
        XCTAssertEqual(mockCoreData.storedCommits.count, 2)
        XCTAssertEqual(mockCoreData.storedCommits.first?["message"] as? String, "Saved Commit 1")
    }
}
