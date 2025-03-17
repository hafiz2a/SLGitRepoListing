//
//  RepositoryVM.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import Foundation
import SL_NetworkModule
import SL_RepoCoreData
import UIKit

class RepositoryVM {
    
    // MARK: - Properties
    
    private(set) var repositories: [Repository] = []
    private var commits: [String: [Commit]] = [:]
    private var commitMessages: [String] = []
    private var networkService = NetworkService(authToken: TEMP_SAMPLE_GITHUB_TOKEN)
    private let coreDataService: CoreDataService
    private var currentPage = 1
    private var isLoading = false
    private(set) var visibleRepositories: [Repository] = [] // Lazy loaded data
    var batchSize = 10 // Number of items per batch
    private var currentIndex = 4 // Tracks the last loaded index , first 5 indexes for collection cells
    private var ongoingRequests: Set<Int> = [] // Track ongoing API calls
    
    var didUpdate: (() -> Void)?
    var didUpdateCommits: (([Int]) -> Void)?
    
    // MARK: - Initializer (Dependency Injection)
    
    init(networkService: NetworkService, coreDataService: CoreDataService) {
        self.networkService = networkService
        self.coreDataService = coreDataService
        loadStoredRepositories()
    }
    // MARK: - Fetch Data
    /// Load stored repositories from Core Data and then fetch fresh data from the API.
    private func loadStoredRepositories() {
        
        let repoDictionaries = coreDataService.fetchRepositories()
        if !repoDictionaries.isEmpty {
            
            repositories = repoDictionaries.map { repoDict in
                
                Repository(id: repoDict["id"] as? Int ?? 0, name: repoDict["name"] as? String ?? "", description: repoDict["repoDesc"] as? String ?? "", html_url: repoDict["html_url"] as? String ?? "")
                
            }
            self.loadNextBatch() // Load first batch
            //            didUpdate?()
        }
        fetchRepositories()
    }
    private func loadStoredCommits(forRepoId repoID: String) {
        let commitDictionaries = coreDataService.fetchCommits(for: repoID)
        let storedCommits = commitDictionaries.compactMap { commitDict -> Commit? in
            guard let sha = commitDict["sha"] as? String,
                  let commitInfo = commitDict["commit"] as? [String: Any], // Ensure commit dictionary exists
                  let message = commitInfo["message"] as? String else { return nil }
            
            return Commit(sha: sha, message: message)
        }
        
        commits[repoID] = storedCommits
    }
    
    
    /// Fetch repositories from GitHub API (with pagination)
    func fetchRepositories() {
        guard !isLoading else { return }
        isLoading = true
        
        networkService.request(endpoint: "users/mralexgray/repos") { (result: Result<[Repository], Error>) in
            //            DispatchQueue.main.async {
            //                guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let repos):
                if self.currentPage == 1 {
                    self.repositories = repos
                } else {
                    self.repositories.append(contentsOf: repos)
                }
                self.saveRepoToCoreData(repository: repos)
                self.loadNextBatch() // Load first batch
                self.didUpdate?()
            case .failure(let error):
                print("Failed to load repositories: \(error.localizedDescription)")
            }
        }
    }
    
    /// Load data batch wise to show up lazy loading ... As API not support paginations
    
    func loadNextBatch() {
        guard currentIndex < repositories.count else { return } // No more data to load
        
        let nextIndex = min(currentIndex + batchSize, repositories.count)
        let newBatch = repositories[currentIndex..<nextIndex]
        visibleRepositories.append(contentsOf: newBatch)
        currentIndex = nextIndex
        
        DispatchQueue.main.async {
            self.didUpdate?()
        }
    }
    
    /// Fetch the next page of repositories (pagination)
    func loadMore() {
        currentPage += 1
        fetchRepositories()
    }
    //MARK: Save Data to CoreData
    
    func saveCommitsToCoreData(commits: [Commit], repositoryID: String) {
        let commitDicts : [[String: Any]] = commits.map { commit in
            return [
                "sha": commit.sha as Any,
                "message": commit.message as Any
            ]
        }
        coreDataService.saveCommits(commitDicts, for: repositoryID)
    }
    func saveRepoToCoreData(repository: [Repository]) {
        let repoDic = repository.map { repo in
            return [
                "id":repo.id,
                "name":repo.name,
                "repoDesc":repo.repoDesc ?? "",
                "htmlURL":repo.html_url ?? ""
            ]
        }
        coreDataService.saveRepositories(repoDic)
    }
    
    //MARK: Get Commits from API for All Visible cells 
    
    func fetchCommitsForVisibleCells(indexPaths: [IndexPath]) {
        guard !indexPaths.isEmpty else { return }
        
        var validRepositories: [(Int, Repository)] = []
        
        for indexPath in indexPaths {
            let rowIndex = indexPath.row
            
            guard rowIndex >= 0, rowIndex < visibleRepositories.count else {
                print("Skipping invalid index: \(rowIndex)")
                continue
            }
            
            let repository = visibleRepositories[rowIndex]
            
            // Skip repositories that already have commits cached or are currently being fetched
            if let cachedCommits = commits[repository.name], !cachedCommits.isEmpty {
                continue
            }
            
            if ongoingRequests.contains(repository.id) {
                continue // API request is already in progress
            }
            
            ongoingRequests.insert(repository.id) // Mark as being fetched
            validRepositories.append((rowIndex, repository))
        }
        
        print("Fetching commits for \(validRepositories.count) repositories")
        
        let commitDispatchGroup = DispatchGroup()
        var updatedIndexes: [Int] = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, repository) in validRepositories {
                commitDispatchGroup.enter()
                
                self.networkService.request(endpoint: "repos/mralexgray/\(repository.name)/commits") { (result: Result<[Commit], Error>) in
                    defer {
                        commitDispatchGroup.leave()
                        self.ongoingRequests.remove(repository.id) // Remove from ongoing requests
                    }
                    
                    switch result {
                    case .success(let fetchedCommits):
                        let latestCommits = Array(fetchedCommits.prefix(3))
                        
                        // Store commits in-memory cache
                        self.commits[repository.name] = latestCommits
                        
                        // Save to Core Data
                        self.saveCommitsToCoreData(commits: latestCommits, repositoryID: repository.name)
                        
                        DispatchQueue.main.async {
                            updatedIndexes.append(index)
                        }
                        
                    case .failure(let error):
                        print("Failed to load commits: \(error.localizedDescription)")
                    }
                }
            }
            
            // Notify main thread when all requests finish
            commitDispatchGroup.notify(queue: .main) {
                self.didUpdateCommits?(updatedIndexes)
            }
        }
    }
    
    func goToDetails(for repository: Repository) -> UIViewController {
        let detailViewModel = RepositoryDetailVM(repository: repository, coreDataService: self.coreDataService,networkService: self.networkService , commitMessages: getCommits(for: repository))
        return RepositoryDetailVC(viewModel: detailViewModel)
    }
    
    /// Get stored commits for a repository
    func getCommits(for repository: Repository) -> [Commit] {
        return commits[repository.name] ?? []
    }
    func toggleExpanded(for repository: Repository, forIndex index: Int) {
        var repo = repository
        repo.isExpanded.toggle()
        self.visibleRepositories[index] = repo
    }
}
