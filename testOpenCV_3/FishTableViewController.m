//
//  FishTableViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 12/23/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "FishTableViewController.h"

@interface FishTableViewController ()

@end

@implementation FishTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    graphTypes = [[NSMutableArray alloc] initWithCapacity: 2];
    [graphTypes addObject:@"Pie Graph"];
    [graphTypes addObject:@"Bar Graph"];
    [graphTypes addObject:@"Line Graph"];
    [graphTypes addObject:@"Multiple Lines Graph"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [graphTypes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [graphTypes objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = @"pie chart";
    }
    else if (indexPath.row == 1) {
        cell.detailTextLabel.text = @"x-axis ROI, y-axis total pixel changes";
    }
    else if (indexPath.row == 2) {
        cell.detailTextLabel.text = @"x-axis ROI, y-axis total pixel changes";
    }
    else if (indexPath.row == 3) {
        cell.detailTextLabel.text = @"x-axis time, y-axis pixel changes, line  ROI";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected table row number %d", indexPath.row);
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"goToPie" sender:self];
    }
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"goToBar" sender:self];
    }
    if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"goToLine" sender:self];
    }
    if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"goToScatter" sender:self];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"Preparing for segue!");
}

@end
