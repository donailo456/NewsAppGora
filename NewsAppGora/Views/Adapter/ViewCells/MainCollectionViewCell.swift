//
//  MainCollectionViewCell.swift
//  NewsAppGora
//
//  Created by Danil Komarov on 18.04.2024.
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MainCollectionViewCell"
    var urlString: String?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "foo"
        label.textColor = .white
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = imageView.bounds
        layer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.clear.cgColor]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView = imageView
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        
        imageView.layer.addSublayer(gradientLayer)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(viewModel: NewsCellModel?) {
        titleLabel.text = viewModel?.title
        imageView.image = UIImage(data: viewModel?.iconData ?? Data())
        urlString = viewModel?.url
    }
}
