//
//  MVVMPeopleViewController.swift
//  MyMessanger
//
//  Created by Roman on 19.03.2026.
//

import UIKit
import FirebaseAuth

class MVVMPeopleViewController: UIViewController, UsersListViewModelDelegate {

    private let currentUser: MUser
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MUser>?

    private let viewModel: UsersListViewModel

    enum Section: Int, CaseIterable {
        case users

        func description(usersCount: Int) -> String {
            "\(usersCount) people nearby"
        }
    }

    init(currentUser: MUser) {
        self.currentUser = currentUser
        self.viewModel = UsersListViewModel(currentUser: currentUser)
        super.init(nibName: nil, bundle: nil)

        title = currentUser.username
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        viewModel.delegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self

        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData()
    }

    // MARK: - UsersListViewModelDelegate
    func usersDidUpdate() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    func errorDidOccur(error: String) {
        DispatchQueue.main.async {
            self.showAlert(with: "Error", end: error)
        }
    }

    func logoutDidSucceed() {
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

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Log out",
            style: .plain,
            target: self,
            action: #selector(signOutTapped)
        )
    }

    @objc private func signOutTapped() {
        viewModel.signOut()
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
            UserCell.self,
            forCellWithReuseIdentifier: UserCell.reuseId
        )

        collectionView.delegate = self
    }

    private func reloadData() {
        let items = filteredUsers
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(items, toSection: .users)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private var filteredUsers: [MUser] {
        return (0..<viewModel.usersCount).compactMap { viewModel.user(at: $0) }
    }
}

// MARK: - DataSource
extension MVVMPeopleViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MUser>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, user -> UICollectionViewCell? in
                guard let self else { return nil }
                guard let section = Section(rawValue: indexPath.section) else { return nil }

                switch section {
                case .users:
                    return self.configure(
                        collectionView: collectionView,
                        cellType: UserCell.self,
                        with: user,
                        for: indexPath
                    )
                }
            }
        )

        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeader.reuseId,
                    for: indexPath
                ) as? SectionHeader else { return nil }
            guard let section = Section(rawValue: indexPath.section) else { return nil }

            let items = self.dataSource?.snapshot().itemIdentifiers(inSection: .users) ?? []
            sectionHeader.configure(
                text: section.description(usersCount: items.count),
                font: .systemFont(ofSize: 36, weight: .light),
                textColor: .label
            )

            return sectionHeader
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MVVMPeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
              section == .users,
              let user = viewModel.user(at: indexPath.item) else { return }

        let profileVC = ProfileViewController(user: user)
        present(profileVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension MVVMPeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchText(searchText.isEmpty ? nil : searchText)
    }
}

// MARK: - Layout
extension MVVMPeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
    }

    private func createUsersSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )
        let spacing = CGFloat(15)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: 15, bottom: 0, trailing: 15
        )

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(1)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

