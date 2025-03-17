//
//  Commit.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 11/03/2025.
//

import Foundation

struct Commit: Codable {
    let sha: String
    let message: String

    private enum CodingKeys: String, CodingKey {
        case sha
        case commit
    }

    private enum CommitKeys: String, CodingKey {
        case message
    }
    
    init(sha: String, message: String) {
        self.sha = sha
        self.message = message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sha = try container.decode(String.self, forKey: .sha)

        let commitContainer = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
        message = try commitContainer.decode(String.self, forKey: .message)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sha, forKey: .sha)

        var commitContainer = container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
        try commitContainer.encode(message, forKey: .message)
    }
}

