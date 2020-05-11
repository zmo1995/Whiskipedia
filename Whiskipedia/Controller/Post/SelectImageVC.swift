//
//  SelectImageVC.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/24/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit
import Photos

private let cellID = "SelectPhotoCell"
private let headerID = "SelectPhotoHeader"
private let NextSegueID = "PhotoToText"

class SelectImageVC: UICollectionViewController , UICollectionViewDelegateFlowLayout{

    //MARK: - Property Setup
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage : UIImage?
    var selectedWhisky : Whisky?
    {
        didSet{
            print(self.selectedWhisky?.Whiskyname!)
        }
    }
    
    var passDelegate : dbForPostVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        btnSetup()
        // Register cell classes
        self.collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: cellID)
        self.collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerID)
        fetchPhotos()
    }
    
    //MARK: - Retrive Keyboard When Touch Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
              self.view.endEditing(true)
          }
          
          func textFieldShouldReturn(_ textField: UITextField) -> Bool {
              textField.resignFirstResponder()
              return true
          }
    

    //MARK: - Navigation Button setup
    
    func btnSetup()
    {
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(goback))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = cancelBtn
        let nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextStep))
        self.navigationItem.rightBarButtonItem = nextBtn
    }

    @objc func nextStep()
    {
        performSegue(withIdentifier: NextSegueID, sender: self)
    }
    
    
    @objc func goback()
    {
        self.dismiss(animated: true) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SelectPhotoCell
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    
    
    //MARK: - Setup Header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! SelectPhotoHeader
        if let selectedimage = self.selectedImage
        {
            if let index = self.images.firstIndex(of: selectedimage)
            {
                // get the asset of selected image
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetsize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetsize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                    self.selectedImage = image
                }
            }
        }
        return header
    }
    
    //Show Selected photo on Header
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.view.frame.width)
    }
    

    //MARK: - CollectionView Layout
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("View width is \(view.frame.width)")
        let width = (UIScreen.main.bounds.size.width - 3.0 ) / 4.0
        print("Cell width is \(width)")
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    //MARK: - Fetch Photos
    
    func getOptions()->PHFetchOptions
    {
        let options = PHFetchOptions()
        
        options.fetchLimit = 30
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        options.sortDescriptors = [sortDescriptor]
        
        return options
    }
    
    func fetchPhotos()
    {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getOptions())
        
        //fetch image in background thread
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                //request image representation for specified object
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image
                    {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil
                        {
                            self.selectedImage = image
                        }
                        if count == allPhotos.count-1
                        {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    //MARK: - Pass Data to Next View 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NextSegueID
        {
            let destination = segue.destination as! TextVC
            destination.selected_whisky = self.selectedWhisky
            destination.PostImage = self.selectedImage
            destination.delegate = self.passDelegate
            
        }
    }
    

}
