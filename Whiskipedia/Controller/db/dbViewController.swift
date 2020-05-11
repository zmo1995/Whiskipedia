//
//  dbViewController.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/8/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Firebase

class dbViewController: UITableViewController {

    
    //MARK: - Property Setup
    @IBOutlet weak var searchBar: UISearchBar!
    var whiskyList : [Whisky] = []
    var index : Int = 0
    let db = Firestore.firestore()
    private let identifier = "WhiskyCell"
    private let segueID = "DBToAddWhisky"
    var Filtered_whiskyList = [Whisky]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Explore"
        searchBar.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        loadwhisky()
        tableView.reloadData()
        
        
    }

    
    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching{
            return Filtered_whiskyList.count
        }
        else {
        return whiskyList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! WhiskyCell
        if searching{
            cell.setup(with: Filtered_whiskyList[indexPath.row])
        }
        else {
        cell.setup(with: whiskyList[indexPath.row])
        }
        return cell
    }
    
    //MARK: - TableView Layout 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
}



    //MARK: - API Methods
extension dbViewController
{
    func loadwhisky()
    {
        let ref = db.collection("Whisky").order(by: "Score",descending: true)
        
        ref.getDocuments { (querysnapshot, error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                for document in querysnapshot!.documents
                {
                    let thisWhisky = document.data() as Dictionary<String,AnyObject>
                    let whisky = Whisky(dic: thisWhisky)
                    self.whiskyList.append(whisky)
                    self.tableView.reloadData()
                }
                
                
                
            }
        }
    }
    
}

    //MARK: - Handle Search Bar
extension dbViewController : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count != 0 {
        Filtered_whiskyList = whiskyList.filter({ (whisky) -> Bool in
            let name = whisky.Whiskyname?.lowercased()
            let country = whisky.Country?.lowercased()
            let type = whisky.type?.lowercased()
            if (name?.contains(searchText.lowercased()))!  || country == searchText.lowercased() || type == searchText.lowercased()
            {
                return true
            }
            else {return false}
        })
        searching = true
            tableView.reloadData()
        }
        else {searching = false
            tableView.reloadData()
        }
    }
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.text = ""
        searching = false
        self.tableView.reloadData()
    }
}


    //MARK: -  Handle Add Whisky
extension dbViewController : addWhiskyVCdelegate
{
    func addWhisky(with newWhisky: Whisky) {
        self.whiskyList.insert(newWhisky, at: 0)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID
        {
            let addWhiskyVC = segue.destination as! addWhiskyVC
            if let Navigation = self.tabBarController?.viewControllers![2] as? UINavigationController
            {
                let postDB = Navigation.viewControllers[0] as! dbForPostVC
                //print(postDB.navigationItem.title! + "**************************")
                addWhiskyVC.post_delegate = postDB

            }
            
            addWhiskyVC.delegate = self
        }
    }
    
}
