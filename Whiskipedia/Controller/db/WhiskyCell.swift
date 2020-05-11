//
//  WhiskyCell.swift
//  Whiskipedia
//
//  Created by ZHI XUAN MO on 4/8/20.
//  Copyright © 2020 zhixuan mo. All rights reserved.
//

import UIKit

class WhiskyCell: UITableViewCell {

    @IBOutlet weak var Name: UILabel!
    
    
    @IBOutlet weak var Cost: UILabel!
    
    
    @IBOutlet weak var Country: UILabel!
    
    @IBOutlet weak var WhiskyType: UILabel!
    
    @IBOutlet weak var Score: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Init with a loaded Whisky 
    
    func setup(with Whisky: Whisky) {
        Name.text = Whisky.Whiskyname
        Cost.text = Whisky.Cost
        Country.text = Whisky.Country
        WhiskyType.text = Whisky.type
        Score.text =  String(format: "%.2f", Whisky.Score ?? 0 )
    }
    
    
    
    
    
}
