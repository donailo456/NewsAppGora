//
//  CollectionViewAdapter.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class CollectionViewAdapter: NSObject {
    
    enum Section {
        case business
        case general
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsCellModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, NewsCellModel>
    
    private weak var collectionView: UICollectionView?
    private var dataSource: DataSource?
    private var snapshot = DataSourceSnapshot()
    
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        
        setupCollectionView()
        configureCollectionViewDataSource()
    }
    
    private func setupCollectionView() {
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.delegate = self
        self.collectionView?.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
    }
    
    private func applySnapshot(weather: NewsCellModel) {
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.business])
        
        snapshot.appendItems([weather])
    
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - UICollectionViewDataSource

extension CollectionViewAdapter {
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView ?? UICollectionView(), cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell

                return cell
        })
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: collectionView.bounds.height - 80)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}
