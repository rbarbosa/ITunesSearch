//
//  DetailViewModel.swift
//  iMusicSearch
//
//  Created by Rui Pedro Barbosa on 07/11/2016.
//  Copyright © 2016 Rui Barbosa. All rights reserved.
//

import Foundation


protocol DetailViewModelDelegate: class {
    
    func imageDataDownloadDidFinished()
}


final class DetailViewModel {
    
    weak var delegate: DetailViewModelDelegate?
    
    let artistName: String
    let trackName: String
    let albumName: String
    let artworkUrl: String
    let price: String
    let releaseDate: String
    let priceTitle: String
    
    private let track: Track
    private let dataSource: ITunesDataSource
    
    var imageData: Data? {
        didSet {
            if imageData != nil {
                print("Did set image data")
                delegate?.imageDataDownloadDidFinished()
            }
        }
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        return dateFormatter
    }()
    
    
    init(track: Track, dataSource: ITunesDataSource) {
        self.track = track
        self.dataSource = dataSource
        
        artistName = track.artistname
        albumName = track.albumName
        trackName = track.trackName
        artworkUrl = track.artworkUrl
        price = String(describing: track.price)
        releaseDate = dateFormatter.string(from: track.releaseDate)
        priceTitle = "Price (\(track.currency))"
        
        downloadImageData()
    }
    
    deinit {
        print("Deinitialized detail view model...")
    }
    
    
    private func downloadImageData() {
        print("Downloading artwork with url: \(artworkUrl)")
        dataSource.downloadImage(from: artworkUrl, completion: { [weak self] data in
            if data != nil {
                self?.imageData = data
            }
        })
    }
}
