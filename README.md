"# final-project-final-cortland

How the App works (so far)
      
      The user must first put in their login information if they want to access and update their current balance of plus dollars and meal swipes.
  
  To do so, they must tap on the right bar button, which will then pull up the LoginViewController. 
  
      The LoginViewController takes in three fields: 
          The user's Computing ID
          The user's NetBadge password
          A user defined pin
          
      The LoginViewController then checks for:
          A user defined pin of 4 characters
              If the pin is valid, it then checks if the NetBadge Login is valid

          If the NetBadge Login is valid, the LoginViewController saves the information onto the keychain, and sets the user defined pin as the key to that login information and closes the current scene. 
       
  To update their current balance, the user can tap on update
      This opens a new scene, which accesses the relevant web service and saves the information regarding the user's balances
      
        Some assumptions:
            
            The user has a good internet connection
            The webpages successfully load within the webview of the update scene.
            The user has a cavadvantage balance
            The user has a plus dollars balance
            The user has a meal swipe balance
       
       If these assumptions aren't met, the app is likely to crash because grabbing the specific elements relies on the webpage successfully loading
       


Optional Features to look out for


    >Consume a pre-built web service 
       Logs into netbadge, grabs the user's plus dollar balance, meal swipe balance, and current date
    
    >Data storage using key/value pair storage --> User Defaults
      Grabs keychain for login, also grabs the user's previous balances when loading the app. 

Dependencies
     
     Alamofire
     SwiftSoup
     KeychainSwift



Finish NetBadge Authentication

      --> Done

Need to figure out how to use that cookie I get
      
      --> Done

Need to figure out how to use keychain
      
      --> Done
  
Need to figure out how to grab CampusDish Data
       
       --> Done but should be looked over and tested
                  Significant issues: time delay... 
                        grabbing data working vs user perceived speed    
                              Fixed issue with a bunch of if statements... goes up to eight seconds and doesn't take in data if longer than that

Need to make firebase with data of all the restaurants that are meal exchange eligible 
            
       --> Done
           
       
Need to work on picking a random restaurant based on shake and then picking an item for subsequent shakes if the restaurant is confirmed
      
       -->
     
Need to work on getting top 5 restaurants closest to the current location
     
      -->


Meal Exchange Restaurants and Menu Items (Firebase)

      --> Making viewcontroller and database for plus dollars way more annoying then I initially thought because I thought all the menu (pricing) data would've been available online but I guess not, so it doesn't seem like I'll do it.

Top 5 Closest Restaurants to the current location

Work Done

            --> 10 pts - Consume a pre-built web service 
                  --> CampusDish and UVA Webservices

            --> 10 pts - Data storage using key/value pair storage (SharedPreferences or UserDefaults) 
                  --> UserDefaults saving login information by using KeychainSwift and a user defined pin
                  
            --> 15 pts - Build and consume your own web service using a third-party platform (i.e Firebase) 
                  --> Uses firebase to build an array of Restaurants by collecting data from a database of of restaurants


Work Left

15 pts - GPS / Location-awareness (includes using Google or Apple Maps) 
- Your app uses the location of the user in some meaningful way in the app. A plain Google Map with just your location and no modification will not earn full credit. (15: Excellent, 12: Good, 9: Reasonable, 6: Has issues, 3: Poor, 0: Does not work)


10 pts - Device Shake 
- Your app responds in an appropriate way to a device shake. "Made up" usages that don't make sense will not earn many points. (10: Excellent, 8: Good, 6: Reasonable, 4: Has issues, 2: Poor, 0: Does not work)
