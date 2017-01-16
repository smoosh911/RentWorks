# RentMatch

RentMatch is an app that helps bring renters and land owners together.

## Documentation

RentMatch is structured using the MVC design pattern.
  - Controllers are split into subgroups as well, i.e. Model Controllers, View Controllers, and other controllers, such as a Firebase Controller that manages functionality having to do with Firebase.

This project utalizes cocoapods and multiple third party frameworks as described below. Make sure to follow the setup instructions below to get started developing this project.

The only code stored in the Git repository for this project is code that is needed. Third party frameworks must be installed during setup. Update gitignore file if you add new frameworks

### Branching Strategy
**Branches**
- *Master branch* with latest finished product.
- *Developer branch* that developers share. The code on this branch should always be finalized as if it is going to be merged into master.
- *Feature branches* are created by developers off of the development branch. Feature branches should not be merged into developer branch until code is finalized. 

**Merging to Master**
Only ever merge develper branch to master. When you merge to master you submit a pull request. An admin will review your code before submitting. Before you submit a pull request, make sure to have a couple people test your new feature on the developer branch to make sure it is functioning properly.

**Creating New Feature**
Whenever you start working on a new feature, create a new feature branch off of the developer branch using the feature name as the branch name.

**Merging to Developer Branch**
Before you merge to developer branch make sure your code is working properly and there are no warnings or errors. Create a merge request and do your best to get a code review from someone else. Make sure you test your feature thoroghly before you submit a pull request.

### Third party libraries/APIs

Facebook SDK for iOS: (version 4.17) (https://developers.facebook.com/docs/ios)
  - FBLogin?
  - Bolts (Included in the Facebook SDK)

Firebase SDK (version 3.8.0)
  - FirebaseAuth (version 3.0.6)
  - FirebaseDatabase (version 3.1.0)
  - FirebaseStorage (version 1.0.4)
  - FirebaseCore (version 3.4.4) (Pretty sure this is required to use the other Firebase frameworks, but there are no functions using it.)

Geonames.org (http://www.geonames.org/export/web-services.html)
  - I am getting city names and locations using this api

DropDown SDK - MIT license
  - Drop down extension. Used for showing locations suggestions when signing up. 

### Maintenance Notes

#### Getting Setup for Development
Follow the steps below to get developing on this project.

1. Clone repository called RentWorks (Make sure you have Git installed)
2. Install cocoapods to your computer (Google it, setup is simple)
3. Install pods into your project
- Open terminal on your Mac
- Navigate to the root directory of the project
- Run the command "pod install"
4. Upon completion open the white pod project file in the root directory to open the project

#### Custom Extensions

  - CoreLibraryExtentions.swift
    - This file has extensions that are intented to provide functionality for the entire project. For example, there is a log function that provides more details logs to the console. 

  - Double: `var isInteger: Bool` returns a boolean whether or not the double can be made into an Int without changing its value.

  - UIView:
      - Various `@IBDesignable` variables to give the 'Tinderesque' swiping cards a drop shadow to add depth.
      - A few normal variables to round corners.

#### Warnings

## Questions and Concerns
If you have any questions or concerns please contact the lead developer Michael Perry at perrmichaelscott@gmail.com
