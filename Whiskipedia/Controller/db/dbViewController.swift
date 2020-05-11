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

    var whiskyList : [Whisky] = []
    var index : Int = 0
    let db = Firestore.firestore()
    private let identifier = "WhiskyCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Explore"
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        loadwhisky()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return whiskyList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! WhiskyCell
        cell.setup(with: whiskyList[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
}














extension dbViewController
{
    func loadwhisky()
    {
        let ref = db.collection("Whisky").order(by: "Score").start(at: [index]).limit(to: 25)
        
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

