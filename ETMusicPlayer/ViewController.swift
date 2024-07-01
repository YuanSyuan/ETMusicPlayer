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
    private var artistResultViewHiddenConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view background color
        view.backgroundColor = .white
        
        // Setup UI elements
        setupUI()
        
        // Setup constraints
        setupConstraints()
        
        // Setup audio session
        setupAudioSession()
        
        // Set delegate for artistResultView
        artistResultView.delegate = self
        artistResultView.isHidden = true
    }
    
    func setupUI() {
        // Configure titleLabel
        titleLabel.text = "Search Music"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        // Configure searchBar
        searchBar.delegate = self
        view.addSubview(searchBar)

        // Configure searchButton
        searchButton.setTitle("Search", for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        view.addSubview(searchButton)

        // Configure tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MusicCell.self, forCellReuseIdentifier: "MusicCell")
        view.addSubview(tableView)
        
        
        // Add artistResultView
        view.addSubview(artistResultView)
    }

    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        artistResultView.translatesAutoresizingMaskIntoConstraints = false

        artistResultViewTopConstraint = artistResultView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8)
//        artistResultViewHiddenConstraint = artistResultView.bottomAnchor.constraint(equalTo: view.topAnchor)

        NSLayoutConstraint.activate([
            // Constraints for titleLabel
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Constraints for searchBar
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Constraints for searchButton
            searchButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Constraints for artistResultView
            artistResultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artistResultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            artistResultView.heightAnchor.constraint(equalToConstant: 200),

            // Constraints for tableView
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Initially hide the artistResultView
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
        searchArtists(query: searchText)
    }

    func searchArtists(query: String) {
            let artists = mockSearchArtists(query: query)
            artistResultView.updateArtists(artists)
            artistResultView.isHidden = artists.isEmpty
            updateArtistResultViewVisibility(show: !artists.isEmpty)
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
    
    func mockSearchArtists(query: String) -> [String] {
        let allArtists = ["Adele", "ABBA", "Ariana Grande", "AC/DC", "Alicia Keys"]
        return allArtists.filter { $0.lowercased().hasPrefix(query.lowercased()) }
    }

    func didSelectArtist(_ artist: String) {
        searchBar.text = artist
        artistResultView.updateArtists([])
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
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MusicCell
        playSong(at: indexPath.row)
    }

    private func playSong(at index: Int) {
        player?.pause()
        playerItem = AVPlayerItem(url: songs[index].previewUrl)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
}
