//
//  LandlordDetailCardViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/31/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import ImageSlideshow

class LandlordCardDetailViewController: DetailCardViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var creditGradeLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var bioTextField: UITextView!
    @IBOutlet weak var aboutLabel: UILabel!
    
    // MARK: variables
    var renter: Renter?
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
//    var tagItems = ["Non-Student", "Employed", "4 Adults, 2 Kids", "Smoking"]
    var tagItems: [String] = []

    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getTagItems()
        updateUI()
    }
    
    // MARK: segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.cardDetailContainerVC.rawValue {
            if let destinationVC = segue.destination as? LandlordCardDetailContainterViewController, let renter = renter {
                destinationVC.renter = renter
            }
        } else if segue.identifier == Identifiers.Segues.reportUserVC.rawValue {
            if let destinationVC = segue.destination as? ReportUserViewController, let renter = self.renter {
                destinationVC.userBeingReported = renter
            }
        }
    }
    
    // TO DO: connect flag buttons
    @IBAction func flagBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: Identifiers.Segues.reportUserVC.rawValue, sender: self)
    }
    
    // MARK: helper functions
    private func updateUI() {
        guard let renter = renter, let firstName = renter.firstName, let lastName = renter.lastName else { return }
        
        setupImages()
        
        userNameLabel.text = "\(firstName) \(lastName)"
        creditGradeLabel.text = renter.creditRating
//        availabilityLabel.text = renter.startAt - not in the database yet
        bioTextField.text = renter.bio
        aboutLabel.text = "About " + firstName
    }
    
    private func setupImages() {
        guard let renter = renter else { return }
        
        var profilePicture: UIImage?
        if let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
            profilePicture = profilePic
        } else {
            log("ERROR: couldn't load a profile image")
            profilePicture = #imageLiteral(resourceName: "noImageProfile90x90")
        }
        
        imageView.image = profilePicture
        secondImageView.image = profilePicture
        backgroundImageView.image = profilePicture
        backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        
        blurImageView(imageView: self.backgroundImageView)
        zoomImageView(imageView: self.backgroundImageView)
    
        imageView.layer.cornerRadius = imageView.frame.width / 2
        secondImageView.layer.cornerRadius = secondImageView.frame.width / 2
        
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        secondImageView.layer.masksToBounds = true
    }

    private func blurImageView(imageView: UIImageView) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.9
        imageView.addSubview(blurEffectView)
    }

    private func zoomImageView(imageView: UIImageView) {
        if let image = imageView.image {
            let newWidth = imageView.frame.width * 1.3
            let scale = newWidth / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imageView.image = newImage
        }
    }
    
    private func getTagItems() {
        // temporary until actual values are decided on.
        guard let renter = renter else { return }
        if renter.isStudent {
            tagItems.append("Student")
        } else {
            tagItems.append("Non-Student")
        }
        
        if renter.wantsSmoking {
            tagItems.append("Smoking")
        }
        
        if renter.wantsPetFriendly {
            tagItems.append("pets")
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! TagCollectionViewCell
    
        cell.tagLabel.text = self.tagItems[indexPath.item]
        cell.tagLabel.sizeToFit()
        cell.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tagString = tagItems[indexPath.item]
        let cellSize: CGSize = tagString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0)])
        return cellSize
    }
}
