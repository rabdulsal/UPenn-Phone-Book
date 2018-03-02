//
//  FavoritesGroupTitleView.swift
//  Phone Book
//
//  Created by Rashad Abdul-Salam on 1/19/18.
//  Copyright © 2018 UPenn. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritesGroupTitleDelegate {
    func pressedEmailGroup(groupIndex: Int)
    func pressedEditGroupTitle(groupIndex: Int)
    func pressedMoreButton(groupIndex: Int)
}

class FavoritesGroupTitleView : UITableViewHeaderFooterView {
    
    @IBOutlet weak var groupTitle: UPennLabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    
    var sectionIndex: Int!
    var favortiesGroupDelegate: FavoritesGroupTitleDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    @IBAction func pressedEditButton(_ sender: UIButton) {
        self.favortiesGroupDelegate?.pressedEditGroupTitle(groupIndex: self.sectionIndex)
    }
    
    @IBAction func pressedTextButton(_ sender: UIButton) {
        self.favortiesGroupDelegate?.pressedMoreButton(groupIndex: self.sectionIndex)
    }
    
    @IBAction func pressedEmailButton(_ sender: UIButton) {
        self.favortiesGroupDelegate?.pressedEmailGroup(groupIndex: self.sectionIndex)
    }
    
    func configure(with delegate: FavoritesGroupTitleDelegate,
                   groupTitle: String,
                   groupTextIsVisible: Bool,
                   groupEmailIsVisible: Bool,
                   and sectionIndex: Int) {
        // Set delegate
        self.favortiesGroupDelegate = delegate
        // Set sectionIndex
        self.sectionIndex = sectionIndex
        // Set Group Title
        self.groupTitle.textColor = UIColor.white
        self.groupTitle.text = groupTitle
        self.groupTitle.setFontHeight(size: 20)
        self.textButton.isHidden = !groupTextIsVisible && !groupEmailIsVisible
    }
    
}

private extension FavoritesGroupTitleView {
    
    func xibSetup() {
        backgroundView = UIView(frame: bounds)
        backgroundView?.backgroundColor = UIColor.upennMediumBlue
    }
}
