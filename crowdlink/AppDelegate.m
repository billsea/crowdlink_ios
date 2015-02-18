//
//  AppDelegate.m
//  crowdlink
//
//  Created by William Seaman on 2/17/15.
//  Copyright (c) 2015 Loudsoftware. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "FriendsTableViewController.h"
#import "LoginViewController.h"
#import "SettingsTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize tabBarController = _tabBarController;
@synthesize UserFacebookID = _UserFacebookID;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //check ios version
    NSString * version = [[UIDevice currentDevice] systemVersion];
    NSLog(@"ios version: %@", version);
    
    [self NotificationSetup];
    
    //facebook signon
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile,Email,user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        //show main view
        [self createNavigationRootView];
    }
    else
    {
        
        //show user login view
        [self LoginView];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Notifications
- (void)NotificationSetup
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthenticationSuccessHandler:)
                                                 name:kFacebookAuthenticationSuccessNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookAuthenticationFailedHandler:)
                                                 name:kFacebookAuthenticationFailedNotification
                                               object:nil];
    
}

- (void)facebookAuthenticationSuccessHandler:(NSNotification*)notification
{
    //show main view
    [self createNavigationRootView];
}

- (void)facebookAuthenticationFailedHandler:(NSNotification*)notification
{
    [self showMessage:@"Facebook login failed" withTitle:@"Login Failed"];
}

- (bool)LoginView
{
    LoginViewController * loginController = [[LoginViewController alloc] init];
    UINavigationController *loginNavController = [[UINavigationController alloc]
                                                  initWithRootViewController:loginController];
    //[loginNavController.navigationBar  setBarTintColor:navBarBgWithImage];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[self window] setRootViewController: loginNavController];
    [[self window] makeKeyAndVisible];
    
    return true;
}


#pragma mark - Facebook methods
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}



// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Confirm logout message
    [self showMessage:@"You're now logged out" withTitle:@""];
    [self LoginView];

}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        
        //user info
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
            } else {
                // retrive user's details at here as shown below
                //public profile,id,name,first_name,last_name,link
                //    gender,locale,timezone,pdated_time,verified
                 //                   NSLog(@"FB user ID:%@",user.id);
                //                     NSLog(@"FB user Link:%@",user.link);
                //                    NSLog(@"FB user first name:%@",user.first_name);
                //                    NSLog(@"FB user last name:%@",user.last_name);
                //                    NSLog(@"FB user birthday:%@",user.birthday);
                //                    NSLog(@"FB user location:%@",user.location);
                //                    NSLog(@"FB user username:%@",user.username);
                //                    NSLog(@"FB user gender:%@",[user objectForKey:@"gender"]);
                //                    NSLog(@"email id:%@",[user objectForKey:@"email"]);
                //                    NSLog(@"location:%@", [NSString stringWithFormat:@"Location: %@\n\n",
                //                                           user.location[@"name"]]);
                
                //NSString *userName = [user name];
                //NSString * userEmail =[user objectForKey:@"email"];
                
                //set this users facebook id
                _UserFacebookID = user.id;
                
                
            }
        }];
        
        //show main application view
        [self createNavigationRootView];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    if(state==FBSessionStateCreated)
    {
        
    }
    
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}



#pragma mark Build Navigation

-(BOOL)createNavigationRootView
{
    //create viewControllers
    FriendsTableViewController * friendsTableView;
    
    @try {
        friendsTableView = [[FriendsTableViewController alloc] init];
        // [[CustomerSharedModel sharedModel] setMainViewController:mainViewController];
    }
    @catch (NSException *exception) {
        friendsTableView = nil;
        NSString *alertString = [NSString stringWithFormat:@"There was an error while initializing the friends view"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error initializing friends view" message:alertString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    
    //clients tab
    UINavigationController *friendsNavController = [[UINavigationController alloc]
                                                 initWithRootViewController:friendsTableView];
    friendsNavController.tabBarItem.title = @"Friends";
    friendsNavController.tabBarItem.image = [UIImage imageNamed:@"conference-32.png"];//set tab image
    
    
    //settings tab
    SettingsTableViewController * settingsTableView = [[SettingsTableViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc]
                                                     initWithRootViewController:settingsTableView];
    settingsNavController.tabBarItem.title = @"Settings";
    settingsNavController.tabBarItem.image = [UIImage imageNamed:@"settings3-32.png"];
   

//    //profile tab
//    ProfileTableViewController * profileView = [[ProfileTableViewController alloc] init];
//    UINavigationController * profileNavController=[[UINavigationController alloc] initWithRootViewController:profileView];
//    profileNavController.tabBarItem.title = @"My Profile";
//    profileNavController.tabBarItem.image = [UIImage imageNamed:@"administrator-32.png"];
    
    
    //add all nav controllers to stack
    NSArray *viewControllers;
    if(friendsTableView != nil)
        viewControllers = [NSArray arrayWithObjects:friendsNavController, settingsNavController,nil];
    else
        viewControllers = [NSArray arrayWithObjects:friendsNavController, settingsNavController,nil];
    
    
    
    //load tab bar with view controllers
    // if valid request, add views to tab bar
    self.tabBarController=[[UITabBarController alloc]init];
    [self.tabBarController setViewControllers:viewControllers];
    self.tabBarController.delegate=self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[self window] setRootViewController: self.tabBarController];
    [[self window] makeKeyAndVisible];
    
    
    return YES;
}



#pragma mark utility methods
// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.loudsoftware.crowdlink" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"crowdlink" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"crowdlink.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
