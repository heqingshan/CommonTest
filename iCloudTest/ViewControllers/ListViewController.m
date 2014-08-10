//
//  ListViewController.m
//  iCloud App
//
//  Created by iRare Media on 11/8/13.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

#import "ListViewController.h"
#import "DocumentViewController.h"

@interface ListViewController () {
    NSMutableArray *fileNameList;
    NSMutableArray *fileObjectList;
    UIRefreshControl *refreshControl;
    
    NSString *fileText;
    NSString *fileTitle;
} @end

@implementation ListViewController

#pragma mark - View Lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup iCloud
    iCloud *cloud = [iCloud sharedCloud]; // This will help to begin the sync process and register for document updates
    [cloud setDelegate:self]; // Set this if you plan to use the delegate
    [cloud setVerboseLogging:YES]; // We want detailed feedback about what's going on with iCloud, this is OFF by default
    
    // Setup File List
    if (fileNameList == nil) fileNameList = [NSMutableArray array];
    if (fileObjectList == nil) fileObjectList = [NSMutableArray array];
    
    // Display an Edit button in the navigation bar for this view controller.
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDocumentVC:)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDocumentVC:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:cancel, add, nil] animated:YES];
    
    // Create refresh control
    if (refreshControl == nil) refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshCloudList) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    // Subscribe to iCloud Ready Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCloudListAfterSetup) name:@"iCloud Ready" object:nil];
}

- (void)addDocumentVC:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
    DocumentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DocumentViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancelDocumentVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *vc = [storyboard instantiateInitialViewController];
//    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    // Call Super
    [super viewWillAppear:YES];
    
    // Present Welcome Screen
    if ([self appIsRunningForFirstTime] == YES || [[iCloud sharedCloud] checkCloudAvailability] == NO || [[NSUserDefaults standardUserDefaults] boolForKey:@"userCloudPref"] == NO) {
        //[self performSegueWithIdentifier:@"showWelcome" sender:self];
        return;
    }
    
    /* --- Force iCloud Update ---
     This is done automatically when changes are made, but we want to make sure the view is always updated when presented */
    [[iCloud sharedCloud] updateFiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)appIsRunningForFirstTime {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        // App already launched
        return NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        return YES;
    }
}

#pragma mark - iCloud Methods

- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer {
    if (!cloudIsAvailable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Unavailable" message:@"iCloud is no longer available. Make sure that you are signed into a valid iCloud account." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        [self performSegueWithIdentifier:@"showWelcome" sender:self];
    }
}

- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames {
    // Get the query results
    NSLog(@"iCloudFilesDidChange Files: %@", fileNames);
    
    fileNameList = fileNames; // A list of the file names
    fileObjectList = files; // A list of NSMetadata objects with detailed metadata
    
    if (refreshControl.isRefreshing) {
        [refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
}

- (void)refreshCloudList {
    [[iCloud sharedCloud] updateFiles];
}

- (void)refreshCloudListAfterSetup {
    // Reclaim delegate and then update files
    [[iCloud sharedCloud] setDelegate:self];
    [[iCloud sharedCloud] updateFiles];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [fileNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *fileName = [fileNameList objectAtIndex:indexPath.row];
    
    NSNumber *filesize = [[iCloud sharedCloud] fileSize:fileName];
    NSDate *updated = [[iCloud sharedCloud] fileModifiedDate:fileName];
    
    __block NSString *documentStateString = @"";
    [[iCloud sharedCloud] documentStateForFile:fileName completion:^(UIDocumentState *documentState, NSString *userReadableDocumentState, NSError *error) {
        if (!error) {
            documentStateString = userReadableDocumentState;
        }
    }];
    
    NSString *fileDetail = [NSString stringWithFormat:@"%@ bytes, updated %@.\n%@", filesize, [MHPrettyDate prettyDateFromDate:updated withFormat:MHPrettyDateFormatWithTime], documentStateString];
    
    // Configure the cell...
    cell.textLabel.text = fileName;
    cell.detailTextLabel.text = fileDetail;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.imageView.image = [self iconForFile:fileName]; // Uncomment this line to enable file icons for each cell
    
    if ([documentStateString isEqualToString:@"Document is in conflict"]) {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[iCloud sharedCloud] retrieveCloudDocumentWithName:[fileNameList objectAtIndex:indexPath.row] completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            fileText = [[NSString alloc] initWithData:documentData encoding:NSUTF8StringEncoding];
            fileTitle = cloudDocument.fileURL.lastPathComponent;
            
            [[iCloud sharedCloud] documentStateForFile:fileTitle completion:^(UIDocumentState *documentState, NSString *userReadableDocumentState, NSError *error) {
                if (!error) {
                    if (*documentState == UIDocumentStateInConflict) {
                        [self performSegueWithIdentifier:@"showConflict" sender:self];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    } else {
                        [self performSegueWithIdentifier:@"documentView" sender:self];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                } else {
                    NSLog(@"Error retrieveing document state: %@", error);
                }
            }];
        } else {
            NSLog(@"Error retrieveing document: %@", error);
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[iCloud sharedCloud] deleteDocumentWithName:[fileNameList objectAtIndex:indexPath.row] completion:^(NSError *error) {
            if (error) {
                NSLog(@"Error deleting document: %@", error);
            } else {
                [[iCloud sharedCloud] updateFiles];
                
                [fileObjectList removeObjectAtIndex:indexPath.row];
                [fileNameList removeObjectAtIndex:indexPath.row];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"documentView"]) {
        // Get reference to the destination view controller
        DocumentViewController *viewController = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [viewController setFileText:fileText];
        [viewController setFileName:fileTitle];
    } else if ([[segue identifier] isEqualToString:@"newDocument"]) {
        // Get reference to the destination view controller
        DocumentViewController *viewController = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [viewController setFileText:@"Document text"];
        [viewController setFileName:@""];
    }
}

#pragma mark - Goodies

- (UIImage *)iconForFile:(NSString *)documentName {
    UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[[[iCloud sharedCloud] ubiquitousDocumentsDirectoryURL] URLByAppendingPathComponent:documentName]];
    if (controller) {
        return [controller.icons lastObject]; // arbitrary selection--gives you the largest icon in this case
    }
    
    return nil;
}

@end
