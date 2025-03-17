//
//  RepositoryDetailVM.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 13/03/2025.
//

import Foundation
import UIKit
import SL_RepoCoreData
import SL_NetworkModule

class RepositoryDetailVM {
    
    private let repository: Repository
    private let coreDataService: CoreDataService
    private var networkService = NetworkService(authToken: TEMP_SAMPLE_GITHUB_TOKEN)
    private(set) var commitMessages: [Commit] = []
    
    var onCommitsFetched: (() -> Void)?  // Callback to notify the controller
    
    init(repository: Repository, coreDataService: CoreDataService, networkService: NetworkService, commitMessages: [Commit]) {
        self.repository = repository
        self.coreDataService = coreDataService
        self.networkService = networkService
        self.commitMessages = commitMessages
    }
    
    func fetchRepositoryDetails(completion: @escaping (String, String?, [Commit]) -> Void) {
        let title = repository.name
        let description = repository.repoDesc

        // If commits are already available, return immediately
        if !self.commitMessages.isEmpty {
            completion(title, description, self.commitMessages)
            return
        }

        // Otherwise, fetch commits from API and return after fetching
        fetchCommitFromAPI { [weak self] in
            guard let self = self else { return }
            completion(title, description, self.commitMessages)
        }
    }

    
    func fetchCommits() {
        loadStoredCommits(forRepoId: repository.name)
//        DispatchQueue.main.async {
//            self.onCommitsFetched?() // Notify the ViewController
//        }
    }
    
    private func loadStoredCommits(forRepoId repoID: String) {
        let commitDictionaries = self.coreDataService.fetchCommits(for: repoID)
        
        if commitDictionaries.isEmpty {
            
            for i in 0..<3 {
                let commit = Commit(sha: "", message: "Commit \(i)")
                self.commitMessages.append(commit)
            }
        }else{
            self.commitMessages = commitDictionaries.compactMap { commitDict -> Commit? in
                    guard let sha = commitDict["sha"] as? String,
                          let message = commitDict["message"] as? String else { return nil }
                    
                    return Commit(sha: sha, message: message)
                }
        }
        
    }
    
    func fetchCommitFromAPI(completion: (() -> Void)? = nil) {
        
        self.networkService.request(endpoint: "repos/mralexgray/\(repository.name)/commits") { (result: Result<[Commit], Error>) in
            
            switch result {
            case .success(let fetchedCommits):
                let latestCommits = Array(fetchedCommits.prefix(3))
                
                // Store commits in-memory cache
                self.commitMessages = latestCommits
                
                // Save to Core Data
                self.saveCommitsToCoreData(commits: latestCommits, repositoryID: self.repository.name)
                
                DispatchQueue.main.async {
                    completion?()
                    self.onCommitsFetched?()
                }
                
                
            case .failure(let error):
                print("Failed to load commits: \(error.localizedDescription)")
            }
        }
    }
    
    func saveCommitsToCoreData(commits: [Commit], repositoryID: String) {
        let commitDicts : [[String: Any]] = commits.map { commit in
            return [
                "sha": commit.sha as Any,
                "message": commit.message as Any
            ]
        }
        coreDataService.saveCommits(commitDicts, for: repositoryID)
    }
    
}

