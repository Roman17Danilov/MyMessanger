//
//  MVVMListViewController.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import UIKit
import FirebaseFirestore

class MVVMListViewController: UIViewController, ChatListViewModelDelegate {

    private let currentUser: MUser
    private var collectionView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?

    private let viewModel: ChatListViewModel

    enum Section: Int, CaseIterable {
        case waitingChats, activeChats

        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting chats"
            case .activeChats:
                return "Active chats"
            }
        }
    }

    init(currentUser: MUser) {
        self.currentUser = currentUser
        self.viewModel = ChatListViewModel(currentUser: currentUser)
        super.init(nibName: nil, bundle: nil)

        title = currentUser.username
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData()
    }

    // MARK: - ChatListViewModelDelegate
    func chatsDidUpdate() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    func errorDidOccur(error: String) {
        DispatchQueue.main.async {
            self.showAlert(with: "Error", end: error)
        }
    }

    // MARK: - UI
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()

        let searchController = UISearchController(searchResultsController: nil)

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createCompositionalLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()

        view.addSubview(collectionView)

        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseId
        )

        collectionView.register(
            ActiveChatCell.self,
            forCellWithReuseIdentifier: ActiveChatCell.reuseId
        )

        collectionView.register(
            WaitingChatCell.self,
            forCellWithReuseIdentifier: WaitingChatCell.reuseId
        )

        collectionView.delegate = self
    }

    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        snapshot.appendSections([.waitingChats, .activeChats])

        snapshot.appendItems(
            Array(viewModel.allWaitingChats),
            toSection: .waitingChats
        )

        snapshot.appendItems(
            Array(viewModel.allActiveChats),
            toSection: .activeChats
        )

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - DataSource
extension MVVMListViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MChat>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, chat -> UICollectionViewCell? in
                guard let self else { return nil }
                guard let section = Section(rawValue: indexPath.section) else { return nil }

                switch section {
                case .waitingChats:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: WaitingChatCell.self,
                        with: chat,
                        for: indexPath
                    )
                case .activeChats:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: ActiveChatCell.self,
                        with: chat,
                        for: indexPath
                    )
                }
            }
        )

        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard self != nil,
                  let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: SectionHeader.reuseId,
                      for: indexPath
                  ) as? SectionHeader else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return nil }

            sectionHeader.configure(
                text: section.description(),
                font: .laoSangamMN20(),
                textColor: UIColor(white: 0.6, alpha: 1.0)
            )

            return sectionHeader
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MVVMListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .waitingChats:
            if let chat = viewModel.waitingChat(at: indexPath) {
                let chatRequestVC = MVVMChatRequestViewController(chat: chat)
                chatRequestVC.delegate = self
                present(chatRequestVC, animated: true)
            }
        case .activeChats:
            if let chat = viewModel.activeChat(at: indexPath) {
                let chatsVC = MVVMChatViewController(user: currentUser, chat: chat)
                navigationController?.pushViewController(chatsVC, animated: true)
            }
        }
    }
}

// MARK: - WaitingChatsNavigation
extension MVVMListViewController: WaitingChatsNavigation {
    func removeWaitingChat(chat: MChat) {
        viewModel.removeWaitingChat(chat: chat)
    }

    func chatToActive(chat: MChat) {
        viewModel.changeToActive(chat: chat)
    }
}

// MARK: - UISearchBarDelegate
extension MVVMListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData()
    }
}

// MARK: - Layout
extension MVVMListViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }

            switch section {
            case .waitingChats:
                return self.createWaitingChats()
            case .activeChats:
                return self.createActiveChats()
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config

        return layout
    }

    private func createWaitingChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(88),
            heightDimension: .absolute(88)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: 20, bottom: 0, trailing: 20
        )
        section.orthogonalScrollingBehavior = .continuous

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func createActiveChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: 20, bottom: 0, trailing: 20
        )

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        return sectionHeader
    }
}

