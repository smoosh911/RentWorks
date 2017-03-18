//
//  ATHMultiSelectionControlSegmentButton.swift
//  Pods
//
//  Created by Athanasios Theodoridis on 06/06/16.
//
//

import Foundation
import UIKit

import QuartzCore

internal class FilterMultiSelectionControlSegmentButton: UIButton {
    
    // MARK: - Private Properties
    fileprivate var _isButtonSelected: Bool = false
    fileprivate var _isButtonEnabled: Bool = true
    
    // MARK: - Public Properties
    /// Whether the button is currently in a selected state
    internal var isButtonSelected: Bool {
        return _isButtonSelected
    }
    /// Whether the button
    internal var isButtonEnabled: Bool {
        return _isButtonEnabled
    }
    
    override var isHighlighted: Bool {
        
        didSet {
            
            // ignore highlighting if button is disabled
            if !_isButtonEnabled { return }
            
            if isHighlighted {
                backgroundColor = tintColor.withAlphaComponent(0.1)
            } else {
                
                if _isButtonSelected {
                    backgroundColor = tintColor
                } else {
                    backgroundColor = UIColor.clear
                }
                
            }
            
        }
    }
    
    // MARK: - Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        _configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private Methods
    /**
     Configures the initial style of the button
     - Sets title color
     - Clears background color
     - Adds a border of 0.5 px
     */
    fileprivate func _configureButton() {
        
        backgroundColor = UIColor.clear
        
        layer.borderWidth = 0.5
        layer.borderColor = tintColor.cgColor
        // 03/11/2017 Candice Davis
        frame.size.height = 34
        titleLabel?.font = UIFont(name: "SF UI Text", size: 14.0)!
    }
    
    /**
     Styles the button as selected
     */
    fileprivate func _setSelectedState() {
        
        layer.borderColor = backgroundColor?.cgColor
        backgroundColor = tintColor
        // 03/11/2017 Candice Davis
        setTitleColor(UIColor(red:0.15, green:0.16, blue:0.24, alpha:1.0), for: .normal)
        
    }
    
    /**
     Styles the button as deselected
     */
    fileprivate func _setDeselectedState() {
        
        backgroundColor = UIColor.clear
        // 03/11/2017 Candice Davis
        setTitleColor(UIColor(red:0.15, green:0.16, blue:0.24, alpha:1.0), for: .normal)
        layer.borderColor = tintColor.cgColor
        
    }
    
    // MARK: - Public Methods
    /**
     Toggles the receiver's selection state and styles it appropriately
     */
    internal func setButtonSelected(_ isSelected: Bool) {
        
        _isButtonSelected = isSelected
        _isButtonSelected ? _setSelectedState() : _setDeselectedState()
        
    }
    
    /**
     Toggles the receiver's enabled/disabled state and styles it appropriately
     */
    internal func setButtonEnabled(_ isEnabled: Bool) {
        
        if isEnabled {
            _setDeselectedState()
        } else {
            setTitleColor(UIColor.gray, for: .normal)
            backgroundColor = UIColor.clear
        }
        
        _isButtonEnabled = isEnabled
        
    }
    
}
