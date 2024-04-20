//
//  CollectionViewAdapter.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class CollectionViewAdapter: NSObject {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsCellModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, NewsCellModel>
    
    private weak var collectionView: UICollectionView?
    private var dataSource: DataSource?
    private var snapshot = DataSourceSnapshot()
    private var cellDataSource: [NewsCellModel]? = []
    private var cellDataSourceNew: [NewsCellModel] = []
    private var cellDataSourceBus: [NewsCellModel]?
    private var cellDataSourceGen: [NewsCellModel]?
    private var sections: [Section] = []
    private var sections2: [SectionData]?
    
    init(collectionView: UICollectionView) {
        super.init()
        self.collectionView = collectionView
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        self.collectionView?.backgroundColor = .blue
        self.collectionView?.delegate = self
        self.collectionView?.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
    }
    
    
    func reload(_ data: [NewsCellModel]?, section: Section) {
        guard let detailDataSource = data else { return }
        sections.append(section)
        cellDataSource? += data ?? []
        if section == .business {
            cellDataSourceBus = data
        }
        else {
            cellDataSourceGen = data
        }
        
        configureCollectionViewDataSource()
        
        applySnapshot(detailDataSource, section: section)
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    private func applySnapshot(_ data: [NewsCellModel], section: Section) {
        guard let snap = dataSource?.snapshot() else { return }
        snapshot = snap
        snapshot.appendSections(Section.allCases)
//        if section == .business {
            snapshot.appendItems(cellDataSourceBus ?? [], toSection: .business)
//        } else {
            snapshot.appendItems(cellDataSourceGen ?? [], toSection: .generala)
//        }
        
        debugPrint("business" ,snapshot.itemIdentifiers(inSection: .business))
        debugPrint("generala", snapshot.itemIdentifiers(inSection: .generala))
        debugPrint(snapshot.numberOfItems)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - UICollectionViewDataSource

extension CollectionViewAdapter {
    private func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView ?? UICollectionView(), cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            let cellType = self.sections[indexPath.section]
            switch cellType {
            case .business:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell
                let cellViewModel = self.cellDataSourceBus?[indexPath.row]
                cell?.configure(viewModel: cellViewModel)
                return cell
            case .generala:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell
                let cellViewModel = self.cellDataSourceGen?[indexPath.row]
                cell?.configure(viewModel: cellViewModel)
                return cell
            }
        
        
        })
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32, height: collectionView.bounds.height - 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}
