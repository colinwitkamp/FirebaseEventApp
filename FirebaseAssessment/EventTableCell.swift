//
//  EventTableCell.swift
//  FirebaseAssessment
//
//  Created by Dev on 7/13/17.
//  Copyright © 2017 Colin. All rights reserved.
//

import UIKit
import SDWebImage

class EventTableCell: UITableViewCell {
    
    @IBOutlet weak var m_lblName: UILabel!
    @IBOutlet weak var m_lblDate: UILabel!
    @IBOutlet weak var m_lblPrice: UILabel!
    @IBOutlet weak var m_lblAddress: UILabel!
    @IBOutlet weak var m_imgImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setEvent(event: Event) {
        // valid name
        if (event.Name != "") {
            m_lblName.text = event.Name
        } else {
            m_lblName.text = "_"
        }
        
        // valid date
        if (event.Date != 0) {
            let date = Date(timeIntervalSince1970: event.Date / 1000) // Firebase
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            m_lblDate.text = formatter.string(from: date)
            
        } else {
            m_lblDate.text = "_"
        }
        
        // valid price
        if (event.Price > 0) {
            m_lblPrice.text = "$ \(event.Price)"
        } else {
            m_lblPrice.text = "_"
        }
        
        // valid address
        if (event.Address != "") {
            m_lblAddress.text = event.Address
        } else {
            m_lblAddress.text = "_"
        }
        
        // valid image
        if let url = URL(string: event.Image) {
            m_imgImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            m_imgImage.image = UIImage(named: "placeholder")
        }
        
    }

}
