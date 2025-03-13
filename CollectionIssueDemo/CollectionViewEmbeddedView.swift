//
//  CollectionViewEmbeddedView.swift
//  CollectionIssueDemo
//
//  Created by IT-MAC-02 on 2025/3/13.
//

import UIKit
import Combine

protocol CollectionViewEmbeddedViewDelegate: AnyObject {
    func didTapFooterButton(in view: CollectionViewEmbeddedView)
}

class CollectionViewEmbeddedView: UIView, CollectionViewEmbeddedFooterViewDelegate {
    
    enum Section {
        case main
    }
    
    struct Animal: Hashable {
        let name: String
        let systemName: String
    }
    
    private lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.footerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewEmbeddedFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewEmbeddedFooterView.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
//    typealias DataSource = UICollectionViewDiffableDataSource<Section, Animal>
//    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Animal>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    private lazy var dataSource = makeDataSource()
    private var subscriptions: Set<AnyCancellable> = []
    weak var delegate: CollectionViewEmbeddedViewDelegate?
    @Published private(set) var height: CGFloat = 0
    
//    // Fix data seems to be okay using in the scenario
//    private var animals: [Animal] = [
//        Animal(name: "Dog", systemName: "dog.fill"),
//        Animal(name: "Cat", systemName: "cat.fill"),
//        Animal(name: "Hare", systemName: "hare.fill"),
//        Animal(name: "Lizard", systemName: "lizard.fill"),  // Based on data to determine collectionView size
//        Animal(name: "Bird", systemName: "bird.fill"),
//        Animal(name: "Fish", systemName: "fish.fill")
//    ]
    private var movies: [Movie] = [] {
        didSet {
            updateSnapshot(animated: true)
        }
    }
    let apiKey = "ab78eda72ff6817210f05012a437246c"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        Task {
            do {
                let movies = try await fetchMoviesFromAPI()
                self.movies = movies
            } catch {
                print(error)
            }
        }
        
//        updateSnapshot(animated: true)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func fetchMoviesFromAPI() async throws -> [Movie] {
        let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }
        
        do {
            let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
            return decoded.results
        } catch {
            return []
        }
    }
    
    private func setupBindings() {
        collectionView.publisher(for: \.contentSize)
            .map(\.height)
            .removeDuplicates()
            .assign(to: \.height, on: self)
            .store(in: &subscriptions)
    }
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Movie> { cell, indexPath, movie in
            var content = cell.defaultContentConfiguration()
            content.text = movie.title
            content.secondaryText = movie.overview
            content.secondaryTextProperties.numberOfLines = 3
//            content.image = UIImage(systemName: animal.systemName)
            cell.contentConfiguration = content
        }
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, movie in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewEmbeddedFooterView.reuseIdentifier, for: indexPath) as! CollectionViewEmbeddedFooterView
                footer.delegate = self
                return footer
            } else { return nil }
        }
        
        return dataSource
    }
    
    private func updateSnapshot(animated: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(movies, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func didTapActionButton(_ footer: CollectionViewEmbeddedFooterView) {
        delegate?.didTapFooterButton(in: self)
    }
}

// MARK: - FooterView
protocol CollectionViewEmbeddedFooterViewDelegate: AnyObject {
    func didTapActionButton(_ footer: CollectionViewEmbeddedFooterView)
}

class CollectionViewEmbeddedFooterView: UICollectionReusableView {
    static let reuseIdentifier = "CollectionViewEmbeddedFooterView"
    
    private lazy var actionButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Dismiss"
        let button = UIButton(
            configuration: config,
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                delegate?.didTapActionButton(self)
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: CollectionViewEmbeddedFooterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(actionButton)
        
        let kPadding: CGFloat = 10
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: kPadding),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: kPadding)
        ])
    }
}
