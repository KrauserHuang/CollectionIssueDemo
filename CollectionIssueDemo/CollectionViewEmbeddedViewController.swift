//
//  CollectionViewEmbeddedViewController.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/13.
//

import UIKit
import Combine

class CollectionViewEmbeddedViewController: UIViewController, CollectionViewEmbeddedViewDelegate {
    
    private lazy var embeddedView: CollectionViewEmbeddedView = {
        let view = CollectionViewEmbeddedView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var embeddedViewHeightConstraint: NSLayoutConstraint?
    private var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.addSubview(embeddedView)
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        let kPadding: CGFloat = 20
        NSLayoutConstraint.activate([
            embeddedView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            embeddedView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            embeddedView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: kPadding)
        ])
        
        embeddedViewHeightConstraint = embeddedView.heightAnchor.constraint(equalToConstant: 0)
        embeddedViewHeightConstraint?.isActive = true
    }
    
    private func setupBindings() {
        embeddedView.$height
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                guard let self else { return }
                updateHeightConstraint(height + 1)  // pretty strange here(need to add at least 1 to update the height)
            }
            .store(in: &subscriptions)
    }
    
    private func updateHeightConstraint(_ height: CGFloat) {
        guard let heightConstraint = embeddedViewHeightConstraint else { return }
        heightConstraint.constant = height
        self.view.layoutIfNeeded()
    }
    
    func didTapFooterButton(in view: CollectionViewEmbeddedView) {
        dismiss(animated: true)
    }
}
