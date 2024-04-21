//
//  CollectionViewAdapter.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class CollectionViewAdapter: NSObject {
    
    // MARK: - Internal properties
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsCellModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, NewsCellModel>
    
    // MARK: - Private properties
    
    private weak var collectionView: UICollectionView?
    private var dataSource: DataSource?
    private var snapshot = DataSourceSnapshot()
    private var cellDataSource: [SectionData]?
    private var sections: [Section] = []
    
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        setupCollectionView()
    }
    
    // MARK: - Internal Methods
    
    func reload(_ data: [SectionData]?) {
        guard let detailDataSource = data else { return }
        cellDataSource = detailDataSource
        sections = detailDataSource.compactMap{ $0.key }
        sections.sort { $0.title < $1.title }
        
        configureCollectionViewDataSource()

        applySnapshot()

        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: - Private properties
    
    private func setupCollectionView() {
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
        self.collectionView?.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuserId)
    }
    
    private func applySnapshot() {
        guard let tempSnapshot = dataSource?.snapshot() else { return }
        snapshot = tempSnapshot
        snapshot.appendSections(sections)
        
        cellDataSource?.forEach { element in
            snapshot.appendItems(element.values, toSection: element.key)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - UICollectionViewDataSource

extension CollectionViewAdapter {
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView ?? UICollectionView(), cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell else { return nil }
            
            if let dataTest = self.cellDataSource {
                let section = self.sections[indexPath.section]
                let cellViewModel = dataTest.first(where: { $0.key == section })?.values[indexPath.row]
                cell.configure(viewModel: cellViewModel)
            }
            
            return cell
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuserId, for: indexPath) as? SectionHeader else { return UICollectionReusableView() }
            guard let first = self.dataSource?.itemIdentifier(for: indexPath) else { return UICollectionReusableView() }
            guard let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: first) else { return UICollectionReusableView() }
            
            switch section {
            case .business:
                sectionHeader.title.text = "Business"
            case .entertainment:
                sectionHeader.title.text = "Entertainment"
            case .general:
                sectionHeader.title.text = "General"
            case .science:
                sectionHeader.title.text = "Science"
            case .sports:
                sectionHeader.title.text = "Sports"
            case .technology:
                sectionHeader.title.text = "Technology"
            case .health:
                sectionHeader.title.text = "Health"
            }
            
            return sectionHeader
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell,
           let urlString = cell.urlString,
           let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.bounds.width - 64) / 2, height: (collectionView.bounds.height - 112) / 3)
    }
}

