# RentMatch

RentMatch is an app that helps bring renters and land owners together.

## Documentation

RentMatch is structured using the MVC design pattern.

  - Controllers are split into subgroups as well, i.e. Model Controllers, View Controllers, and other controllers, such as a Firebase Controller that manages functionality having to do with Firebase.

### Third party libraries

Facebook SDK for iOS: (version 4.17) (https://developers.facebook.com/docs/ios)
  - FBLogin?
  - Bolts (Included in the Facebook SDK)

Firebase SDK (version 3.8.0)
  - FirebaseAuth (version 3.0.6)
  - FirebaseDatabase (version 3.1.0)
  - FirebaseStorage (version 1.0.4)
  - FirebaseCore (version 3.4.4) (Pretty sure this is required to use the other Firebase frameworks, but there are no functions using it.)

### Maintenance Notes

#### Custom Extensions

  - Double: `var isInteger: Bool` returns a boolean whether or not the double can be made into an Int without changing its value.

  - UIView:
      - Various `@IBDesignable` variables to give the 'Tinderesque' swiping cards a drop shadow to add depth.
      - A few normal variables to round corners.

#### Warnings
