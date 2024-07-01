//
//  ViewController.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/6/29.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UISearchBarDelegate, ArtistSearchResultViewDelegate {
    
    let musicManager = MusicManager()
    var songs: [StoreItem] = []
    
    // UI elements
    let titleLabel = UILabel()
    let searchBar = UISearchBar()
    let searchButton = UIButton(type: .system)
    let tableView = UITableView()
    let artistResultView = ArtistSearchResultView()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    // Constraints
    private var artistResultViewTopConstraint: NSLayoutConstraint?
    
    var currentlyPlayingIndex: Int?
    var previouslyPlayingIndex: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupAudioSession()
        
        artistResultView.delegate = self
        artistResultView.isHidden = true
    }
    
    func setupUI() {
        titleLabel.text = "Search Music"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .left
        view.addSubview(titleLabel)
        
        searchBar.delegate = self
        searchBar.placeholder = "Enter Keyword here"
        view.addSubview(searchBar)
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.backgroundColor = .black
        searchButton.layer.cornerRadius = 5
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        view.addSubview(searchButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MusicCell.self, forCellReuseIdentifier: "MusicCell")
        view.addSubview(tableView)
        
        view.addSubview(artistResultView)
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        artistResultView.translatesAutoresizingMaskIntoConstraints = false
        
        artistResultViewTopConstraint = artistResultView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            artistResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistResultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            artistResultView.heightAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        artistResultViewTopConstraint?.isActive = false
    }
    
    @objc func searchButtonTapped() {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        musicManager.getAPIData(for: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedSongs):
                    self?.songs = fetchedSongs
                    print(fetchedSongs)
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    print("Error fetching songs: \(error)")
                }
            }
        }
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        player = AVPlayer()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            songs = []
            tableView.reloadData()
            artistResultView.updateArtists([])
            artistResultView.artistTableView.reloadData()
        } else {
            lookupArtist(by: searchText)
        }
    }
    
    func lookupArtist(by searchText: String) {
        musicManager.lookupArtist(by: searchText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    self?.artistResultView.updateArtists(artists)
                    self?.artistResultView.isHidden = artists.isEmpty
                    self?.updateArtistResultViewVisibility(show: !artists.isEmpty)
                case .failure(let error):
                    print("Error fetching artists: \(error)")
                }
            }
        }
    }
    
    func updateArtistResultViewVisibility(show: Bool) {
        if show {
            artistResultViewTopConstraint?.isActive = true
        } else {
            artistResultViewTopConstraint?.isActive = false
            artistResultView.isHidden = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didSelectArtist(_ artist: String) {
        searchBar.text = artist
        updateArtistResultViewVisibility(show: false)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath) as! MusicCell
        let song = songs[indexPath.row]
        cell.configure(with: song)
        cell.playBtn.isHidden = indexPath.row != currentlyPlayingIndex
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MusicCell else { return }
        previouslyPlayingIndex = currentlyPlayingIndex
        currentlyPlayingIndex = indexPath.row
        
        if previouslyPlayingIndex != currentlyPlayingIndex {
            if let previousIndex = previouslyPlayingIndex {
                tableView.reloadRows(at: [IndexPath(row: previousIndex, section: 0)], with: .none)
            }
        }
        togglePlayPause(for: cell, at: indexPath.row)
    }
    
    
    private func togglePlayPause(for cell: UITableViewCell, at index: Int) {
        guard let musicCell = cell as? MusicCell else { return }
        musicCell.playBtn.isHidden = false
        if previouslyPlayingIndex == currentlyPlayingIndex {
            if player?.timeControlStatus == .paused {
                playerItem = AVPlayerItem(url: songs[index].previewUrl)
                player?.replaceCurrentItem(with: playerItem)
                player?.play()
                musicCell.playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                player?.pause()
                musicCell.playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
            
        } else {
            playerItem = AVPlayerItem(url: songs[index].previewUrl)
            player?.replaceCurrentItem(with: playerItem)
            player?.play()
            musicCell.playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
}
