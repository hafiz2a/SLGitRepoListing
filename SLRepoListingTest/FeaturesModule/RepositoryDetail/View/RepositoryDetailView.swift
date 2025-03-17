//
//  RepositoryDetailView.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 13/03/2025.
//

import UIKit

class RepositoryDetailView: UIView {
    
    private let titleLabel = UILabel()
    public let closeButton = UIButton(type: .system)
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let commitsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = true
        
        // Title Label
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        // Close Button
        closeButton.setImage(.close, for: .normal)
        
        // Image View
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .lightGray
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowRadius = 4
        imageView.layer.masksToBounds = false
        
        // Description Label
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        
        // Commits Stack View
        commitsStackView.axis = .vertical
        commitsStackView.spacing = 8
        commitsStackView.alignment = .leading
        commitsStackView.distribution = .equalSpacing
        
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(imageView)
        addSubview(descriptionLabel)
        addSubview(commitsStackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        commitsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            commitsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            commitsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            commitsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            commitsStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, description: String, commits: [Commit]) {
        titleLabel.text = title
        descriptionLabel.text = "Description: \(description)"
        imageView.image = .rectanglePlaceholder
        
        commitsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear previous commits
        
        for commit in commits.prefix(3) {
            let commitLabel = UILabel()
            commitLabel.text = commit.message
            commitLabel.font = .systemFont(ofSize: 14)
            commitsStackView.addArrangedSubview(commitLabel)
        }
    }
}

