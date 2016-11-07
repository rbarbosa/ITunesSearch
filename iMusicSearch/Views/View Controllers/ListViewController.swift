//
//  ListViewController.swift
//  iMusicSearch
//
//  Created by Rui Pedro Barbosa on 05/11/2016.
//  Copyright © 2016 Rui Barbosa. All rights reserved.
//

import UIKit

final class ListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let viewModel = ListViewModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        
        setUpSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setUpTableView() {
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ListCell")
        
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    private func setUpSearchController() {
        //searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        listTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}



// MARK: - UITableViewDataSource methods
extension ListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        return cell
    }
    
}



// MARK: - UITableViewDelegate methods
extension ListViewController: UITableViewDelegate {
    
}



// MARK: - UISeacrBarDelegate methods
extension ListViewController: UISearchBarDelegate {
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            viewModel.search(for: text, completion: { [weak self] error in
                DispatchQueue.main.async(execute: {
                    self?.navigationItem.title = self?.viewModel.title
                    self?.searchController.isActive = false
                    
                    if error == nil {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self?.listTableView.reloadData()
                    } else {
                        // TODO: Display alert with error
                    }
                })
            })
            
        }
        
        return
    }
    
}
