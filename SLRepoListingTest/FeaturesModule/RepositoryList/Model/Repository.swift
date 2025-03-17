//
//  Repository.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 11/03/2025.
//

import Foundation

public struct Repository: Identifiable, Codable {
    public let id: Int
    public let name: String
    public let repoDesc: String?
    public let html_url: String?
    public let avatarUrl: String?
    
    // Internal processing flag (not part of API response)
    public var isExpanded: Bool = true
    
    
    public init(id: Int, name: String, description: String?, html_url: String?, avatarUrl: String? = nil) {
        self.id = id
        self.name = name
        self.repoDesc = description
        self.html_url = html_url
        self.avatarUrl = avatarUrl
        
    }
    
    // Exclude `isProcessing` from Codable
    private enum CodingKeys: String, CodingKey {
        case id, name, repoDesc = "description", html_url, avatarUrl
    }
}
