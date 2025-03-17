//
//  RepositoryDetailVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//


import UIKit

class RepositoryDetailVC: UIViewController {
    // MARK: - Properties
    
    private let viewModel: RepositoryDetailVM
    private let repositoryDetailView = RepositoryDetailView()
    
    private var bottomConstraint: NSLayoutConstraint!
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0) // Initially transparent
        return view
    }()
    // MARK: - Initializer (Dependency Injection)
    
    init(viewModel: RepositoryDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen // Ensure it overlays the screen
        modalTransitionStyle = .coverVertical // Default transition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
        showBottomSheet() // Animate appearance
    }
    
    private func setupUI() {
        // Add background overlay
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        
        view.addSubview(repositoryDetailView)
        repositoryDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom sheet starts off-screen
        bottomConstraint = repositoryDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        
        NSLayoutConstraint.activate([
            repositoryDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            repositoryDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            repositoryDetailView.heightAnchor.constraint(equalToConstant: 400),
            bottomConstraint
        ])
        
        repositoryDetailView.closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // Add swipe-to-dismiss gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        repositoryDetailView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        viewModel.onCommitsFetched = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func loadData() {
        viewModel.fetchRepositoryDetails { title, description, commits in
            DispatchQueue.main.async {
                self.repositoryDetailView.configure(
                    title: title,
                    description: description ?? "",
                    commits: commits
                )
            }
        }


    }
    
    private func updateUI() {
//        repositoryDetailView.configure(
//            title: viewModel.fetchRepositoryDetails().title,
//            description: viewModel.fetchRepositoryDetails().description ?? "",
//            commits: viewModel.commitMessages
//        )
    }
    
    @objc private func closeTapped() {
        hideBottomSheet()
    }
    
    // Show bottom sheet with animation
    private func showBottomSheet() {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    // Hide bottom sheet with animation
    private func hideBottomSheet() {
        bottomConstraint.constant = 400
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0) // Fade out overlay
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // Handle swipe-to-dismiss gesture
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 { // Allow downward swipe only
                bottomConstraint.constant = translation.y
            }
        case .ended:
            if translation.y > 100 { // If swiped enough, dismiss
                hideBottomSheet()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.bottomConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
}

