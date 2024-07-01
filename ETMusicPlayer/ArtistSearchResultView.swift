//
//  ArtistSearchResultView.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/7/1.
//

import UIKit

protocol ArtistSearchResultViewDelegate: AnyObject {
    func didSelectArtist(_ artist: String)
}

class ArtistSearchResultView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let artistTableView = UITableView()
    private var artists: [Artist] = []
    weak var delegate: ArtistSearchResultViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        
        artistTableView.delegate = self
        artistTableView.dataSource = self
        artistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArtistCell")
        self.addSubview(artistTableView)
    }
    
    private func setupConstraints() {
        artistTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artistTableView.topAnchor.constraint(equalTo: self.topAnchor),
            artistTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            artistTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            artistTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func updateArtists(_ artists: [Artist]) {
        self.artists = artists
        artistTableView.reloadData()
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
        cell.textLabel?.text = artists[indexPath.row].artistName
        return cell
    }

    // UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArtist = artists[indexPath.row].artistName
        delegate?.didSelectArtist(selectedArtist)
    }
}
