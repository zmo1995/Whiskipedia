//
//  dbForPostVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/26/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//
import UIKit
import Firebase

class dbForPostVC: UITableViewController , TextVCdelegate{
    
    func reload() {
        loadwhisky()
        self.tableView.reloadData()
    }
    
    //MARK: - Property Setup
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var whiskyList : [Whisky] = []
    var index : Int = 0
    let db = Firestore.firestore()
    private let identifier = "WhiskyCell"
    private let nextStepID = "DBToPhoto"
    var Filtered_whiskyList = [Whisky]()
    var searching = false
    var selected_index : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Choose Your Whisky"
        searchBar.delegate = self
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        loadwhisky()
        self.tableView.keyboardDismissMode = .onDrag
        tableView.reloadData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        reload()
//    }
//    
    

    // MARK: - Table view data source

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
    
    //MARK: - Handle Transition to Detail View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected_index = indexPath.row
        performSegue(withIdentifier: nextStepID, sender: self)
    }
    

   
          
       
    
    
    
}












    //MARK: - API Methods
extension dbForPostVC
{
    func loadwhisky()
    {
        self.whiskyList = [Whisky]()
        self.Filtered_whiskyList = [Whisky]()
        let ref = db.collection("Whisky").order(by: "Score",descending: true)//.start(at: [index]).limit(to: 50)
        
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
                    whisky.ID = document.documentID
                    self.whiskyList.append(whisky)
                    self.tableView.reloadData()
                }
                
                
                
            }
        }
    }
    
}

    //MARK: - Handle Search Bar
extension dbForPostVC : UISearchBarDelegate
{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.searchBar.endEditing(true)
           self.resignFirstResponder()
             }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searching")
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

//MARK: - Pass Selected Whisky Object to next Step
extension dbForPostVC : addWhiskyVCdelegate
{
    func addWhisky(with newWhisky: Whisky) {
        print("Add Whisky Received")
        self.whiskyList.insert(newWhisky, at: 0)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nextStepID , let index = selected_index
        {
            let destination = segue.destination as! SelectImageVC
            if searching{
                destination.selectedWhisky = Filtered_whiskyList[index]
            }
            else {
            destination.selectedWhisky = whiskyList[index]
            }
            destination.passDelegate = self 
        }
    }
    
}
