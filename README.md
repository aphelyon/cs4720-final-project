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
       
       --> 60% 
            --> need to finish time range and the other dining halls
            --> Significant issues: time delay... 
                        grabbing data working vs user perceived speed    

Need to make firebase with data of all the restaurants that are plus dollar and meal exchange eligible 
            
       -->
