//
//  ListViewModel.swift
//  iMusicSearch
//
//  Created by Rui Pedro Barbosa on 05/11/2016.
//  Copyright © 2016 Rui Barbosa. All rights reserved.
//

import Foundation


final class ListViewModel {
    
    var title: String?
    var tracks = [Track]()
    
    private let dataSource = ITunesDataSource()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        return dateFormatter
    }()
    
    
    init() {
        
    }
    
    
    
    // MARK: - Table view data
    func numberOfItems() -> Int {
        return tracks.count
    }
    
    
    
    // MARK: - Cell view model
    func listItelCellViewMode(for indexPath: IndexPath) -> ListItemCellViewModel {
        return ListItemCellViewModel(track: tracks[indexPath.row], dataSource: dataSource)
    }
    
    
    
    // MARK: - Search
    func search(for content: String, completion: @escaping (_ errorMessage: String?) -> Void) {
        title = content
        
        dataSource.search(for: content, completion: { [weak self] tracks, error  in
            if error == nil {
                self?.tracks = tracks!
                completion(nil)
            } else {
                completion(error)
            }
        })
    }
}
