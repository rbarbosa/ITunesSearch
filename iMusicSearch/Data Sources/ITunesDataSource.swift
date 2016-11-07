//
//  ITunesDataSource.swift
//  iMusicSearch
//
//  Created by Rui Pedro Barbosa on 07/11/2016.
//  Copyright © 2016 Rui Barbosa. All rights reserved.
//

import Foundation


final class ITunesDataSource {
    
    struct ITunesKeys {
        static let baseTerm = "https://itunes.apple.com/search?term="
        
        static let kind = "kind"
        static let kindTypeSong = "song"
        
        static let artistName = "artistName"
        static let albumName = "collectionName"
        static let trackName = "trackName"
        static let trackViewUrl = "trackViewUrl"
        static let artworkUrl30 = "artworkUrl30"
        static let artworkUrl60 = "artworkUrl60"
        static let artworkUrl100 = "artworkUrl100"
        static let collectionPrice = "collectionPrice"
        static let trackPrice = "trackPrice"
        static let releaseDate = "releaseDate"
        
    }
    
    private let sessionConfig: URLSessionConfiguration
    private let session: URLSession
    
    private lazy var iTunesDateFormatter: DateFormatter = {
        // 2005-07-05T07:00:00Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd'T'hh:mm:00'Z'"
        return dateFormatter
    }()
    
    
    init() {
        sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig)
    }
    
    
    // MARK: - Search content
    func search(for content: String, completion: @escaping (_ tracks: [Track]?, _ errorMessage: String?) -> Void) {
        // TODO: Add condition if iOS 8
        // let termEncoded = content.addingPercentEscapes(using: String.Encoding.utf8)
        
        let termEncoded = content.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = ITunesKeys.baseTerm.appending(termEncoded!)
        
        print("urlString \(urlString)")
        
        let url = URL(string: urlString)
        guard url != nil else {
            completion(nil, nil)
            return
        }
        
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            print("Data: \(data)")
            print("Response: \(response)")
            if error == nil {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    guard data != nil else {
                        // TODO: Add message to no data
                        completion(nil, "No data received")
                        return
                    }
                    let tracks = self?.handleSearchResults(with: data!)
                    completion(tracks, nil)
                    print("tracks: \(tracks)")
                } else {
                    print("Error: \(error)")
                    completion(nil, error?.localizedDescription)
                }
            } else {
                
            }
        })
        
        task.resume()
    }
    
    
    // MARK: - Handle results
    private func handleSearchResults(with data: Data) -> [Track]? {
        
        var tracks = [Track]()
        
        do {
            let response = try JSONSerialization.jsonObject(with: data,
            options: .allowFragments) as! [String: Any]
            let results = response["results"] as! [[String: Any]]
            
            for item in results {
                if item[ITunesKeys.kind] as! String != ITunesKeys.kindTypeSong {
                    continue
                }
                
                let trackName = item[ITunesKeys.trackName] as! String
                let artistName = item[ITunesKeys.artistName] as! String
                let albumName = item[ITunesKeys.albumName] as! String
                let artworkUrl = item[ITunesKeys.artworkUrl100] as! String
                let artWorkThumbnail = item[ITunesKeys.artworkUrl60] as! String
                let releaseDate = date(from: item[ITunesKeys.releaseDate] as! String)
                let price =  item[ITunesKeys.trackPrice] as! NSNumber
                let trackViewUrl = item[ITunesKeys.trackViewUrl] as! String
                
                let track = Track(trackName: trackName,
                                  artistname: artistName,
                                  albumName: albumName,
                                  artworkUrl: artworkUrl,
                                  artworkThumbnailUrl: artWorkThumbnail,
                                  releaseDate: releaseDate,
                                  price: price,
                                  trackViewUrl: trackViewUrl)
                
                tracks.append(track)
            }
            
            return tracks
        } catch let error as NSError {
            print("Error in json: \(error)")
        }
        
        return nil
    }
    
    
    private func date(from string: String) -> Date {
        return iTunesDateFormatter.date(from: string)!
    }
}
