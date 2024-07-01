//
//  ViewController.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/6/29.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    let musicManager = MusicManager()
    var songs: [StoreItem] = []
    
    // UI elements
    let titleLabel = UILabel()
    let searchBar = UISearchBar()
    let searchButton = UIButton(type: .system)
    let tableView = UITableView()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //TO-DO 改成輸入框文字帶入搜尋
        musicManager.getAPIData(for: "jason mars") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedSongs):
                    self?.songs.append(contentsOf: fetchedSongs)
                    print(self?.songs)
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching songs: \(error)")
                }
            }
        }
        
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupAudioSession()
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
        }

        func setupConstraints() {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchButton.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false

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

                tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 16),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        @objc func searchButtonTapped() {
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                return
            }
//            searchMusic(query: searchText)
        }

//        func searchMusic(query: String) {
//            MusicManager.shared.searchMusic(query: query) { [weak self] results in
//                DispatchQueue.main.async {
//                    self?.searchResults = results
//                    self?.tableView.reloadData()
//                }
//            }
//        }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        player = AVPlayer()
    }
        
    
}

// UITableViewDataSource methods
extension ViewController: UITableViewDataSource{
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
        70
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

