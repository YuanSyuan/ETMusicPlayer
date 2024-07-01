//
//  MusicCell.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/7/1.
//

import UIKit

class MusicCell: UITableViewCell {
    
    // UI elements
    let trackNameLabel = UILabel()
    let trackTimeLabel = UILabel()
    let artworkImageView = UIImageView()
    let playBtn = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // Configure trackNameLabel
        trackNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(trackNameLabel)
        
        // Configure trackTimeLabel
        trackTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        trackTimeLabel.textAlignment = .right
        contentView.addSubview(trackTimeLabel)
        
        // Configure artworkImageView
        artworkImageView.contentMode = .scaleAspectFill
        artworkImageView.clipsToBounds = true
        contentView.addSubview(artworkImageView)
        
        // Configure playButton
        playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playBtn.isHidden = true
        contentView.addSubview(playBtn)
        
        trackTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        trackNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupConstraints() {
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            artworkImageView.widthAnchor.constraint(equalToConstant: 60),
            artworkImageView.heightAnchor.constraint(equalToConstant: 60),
            artworkImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: trackTimeLabel.leadingAnchor, constant: -8),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            trackTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            playBtn.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 16),
            playBtn.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 8),
            playBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with song: StoreItem) {
        trackNameLabel.text = song.trackName
        trackTimeLabel.text = formattedTrackTime(song.trackTimeMillis)
        //        longDescriptionLabel.text = song.longDescription
        
        artworkImageView.loadImage(from: song.artworkUrl100)
    }
    
    private func formattedTrackTime(_ millis: Int) -> String {
        let minutes = millis / 60000
        let seconds = (millis % 60000) / 1000
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Assuming you have an extension or method to load images from URL
extension UIImageView {
    func loadImage(from url: URL) {
        // Example using URLSession (or use a library like SDWebImage)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}

