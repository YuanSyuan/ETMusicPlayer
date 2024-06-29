//
//  ViewController.swift
//  ETMusicPlayer
//
//  Created by 李芫萱 on 2024/6/29.
//

import UIKit

class ViewController: UIViewController {
    
    let musicManager = MusicManager()
    var songs: [StoreItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //TO-DO 改成輸入框文字帶入搜尋
        musicManager.getAPIData(for: "jasonmars") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedSongs):
                    self?.songs.append(contentsOf: fetchedSongs)
                    print(self?.songs)
                case .failure(let error):
                    print("Error fetching songs: \(error)")
                }
            }
        }
    }
    
    
}

