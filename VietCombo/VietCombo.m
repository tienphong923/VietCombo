//
//  VietCombo.m
//  VietCombo
//
//  Created by tienphong923@gmail.com on 8/30/13.
//  Copyright (c) 2013 Z-Team. All rights reserved.
//

#import "VietCombo.h"
#import <QuartzCore/QuartzCore.h>


#define kRowHeight 35

@implementation VietCombo
{
    CGFloat tableHeight;
    CGRect listFrame;
    UIView *shadowView;
    UIView *backgroundView;
}

bool isFirstTime = YES;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupVietCombo];
    }
    return self;
}


//----

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupVietCombo];
    }
    return self;
}

- (void)dealloc
{
    shadowView = nil;
    backgroundView = nil;
    _tableView = nil;
    _dataArray = nil;
    _backgroundColor = nil;
}

//----

- (void)setupVietCombo
{
    //Default
    _selectedIndex = -1;
    tableHeight = 0.0f;
    
    //Handle Button
    [self addTarget:self action:@selector(showListClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Init table
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.cornerRadius = 10;
    _tableView.layer.borderColor = [[UIColor grayColor] CGColor];
    _tableView.layer.borderWidth = 2.0;
    if ([_tableView respondsToSelector:@selector(separatorInset)])
        [_tableView setSeparatorInset:UIEdgeInsetsZero];

    
    //Init shadow view
    shadowView = [[UIView alloc] init];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.layer.shadowOpacity = 0.3;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowRadius = 2;

    //Init background
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    backgroundView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];    //[UIColor colorWithRed:160 green:160 blue:160 alpha:0.6];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTableView:)];
    tapGesture.cancelsTouchesInView = NO;
    
    [backgroundView addGestureRecognizer:tapGesture];
    [backgroundView addSubview:_tableView];
    [backgroundView insertSubview:shadowView belowSubview:_tableView];
    
    //[keyWindow addSubview:backgroundView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)showListClicked:(UIButton *)button
{
    // Don't show tableView when no _dataArray
    if (!_dataArray) {
        return;
    }
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    //Mapping button to keyWindow
    CGPoint point = [keyWindow convertPoint:self.frame.origin fromView:self.superview];
    
    
    //Height for tableView
    NSInteger numberItems = 10; //self.dataArray.count
    float height = numberItems * kRowHeight;
    float top = point.y + self.frame.size.height + 5; //5 = padding top
    float width = self.frame.size.width + 40;
    float left = point.x + 2;
    
    if (point.y + self.frame.size.height + height > keyWindow.bounds.size.height - 20)
        height = keyWindow.bounds.size.height - 20 - (point.y + self.frame.size.height) + 5;

    if (height < kRowHeight + 5) {
        height = numberItems * kRowHeight;
        top = point.y - 5 - height;
        if (top < 10) {
            top = 10;
            height = point.y - 5 - top;
        }
    }
    
    if (left + width > keyWindow.bounds.size.width - 20)
        width = keyWindow.bounds.size.width - left - 20;
    
    // Table Frame
    listFrame = CGRectMake(left, top, width, height);

    // Save table height
    tableHeight = height;

    // Hide tableView
    CGRect tableFrameHidden = CGRectMake(left, top, width, 0);
    _tableView.frame = tableFrameHidden;
    
    // Set frame
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.frame = listFrame;
        shadowView.frame = CGRectMake(left+1, top+1, width, height);
    } completion:^(BOOL finished) {
        //
    }];
    
    //[self.superview addSubview:view];
    [keyWindow addSubview:backgroundView];
    
    [_tableView reloadData];
    
    //Pre selected
    if (_dataArray && _selectedIndex >= 0 && _selectedIndex < _dataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}


#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataArray)
        return _dataArray.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"VietComboCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Key"]];
    
    if (key && [key isEqualToString:@"-"]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.contentView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [dict objectForKey:@"Value"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    
    NSString *key = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Key"]];
    
    if (key && [key isEqualToString:@"-"]) {
        return;
    }
    
    NSString *title = [NSString stringWithFormat:@"%@", [dict objectForKey:@"Value"]];
    
    [self setTitle:title forState:UIControlStateNormal];
    
    //Update selectedIndex
    //_selectedIndex = indexPath.row;
    [self setSelectedIndex:indexPath.row];
    
    //[tableView.superview removeFromSuperview];
    [self hideCombobox];
}


- (void)hideTableView:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:backgroundView];
    
    if (!CGRectContainsPoint(_tableView.frame, touchPoint)) {
        //[[listTable superview] removeFromSuperview];
        //[backgroundView removeFromSuperview];
        [self hideCombobox];
    }
}

- (void)hideCombobox
{
    CGRect frame = _tableView.frame;
    CGRect shadow_frame = CGRectMake(frame.origin.x+1, frame.origin.y+1, frame.size.width, frame.size.height);
    
    frame.size.height = 0.0f;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.frame = frame;
        shadowView.frame = shadow_frame;

    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    backgroundView.backgroundColor = backgroundColor;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    if (_selectedIndex >= 0 && _selectedIndex < _dataArray.count) {
        NSDictionary *selectedItem = [_dataArray objectAtIndex:_selectedIndex];
        [self setTitle:[selectedItem objectForKey:@"Value"] forState:UIControlStateNormal];
        
        // SELECTED DELEGATE
        if (self.delegate && [self.delegate respondsToSelector:@selector(vietCombo:didSelectItem:)]) {
            [self.delegate vietCombo:self didSelectItem:selectedItem];
        }
    }
    else {
        _selectedIndex = -1;
        [self setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)setVietComboStyle:(VietComboStyle)vietComboStyle
{
    _vietComboStyle = vietComboStyle;
    
    switch (vietComboStyle) {
        case VietComboStyleNone:
        {
            UIImage *backgroundImage = nil;
            [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            break;
        }
            
        case VietComboStyleAndroidGray:
        {
            UIImage *backgroundImage = [UIImage imageNamed:@"vietcb_gray"];
            UIEdgeInsets imageInset = UIEdgeInsetsMake(0, backgroundImage.size.width/2,
                                                       backgroundImage.size.height, backgroundImage.size.width/2);
            backgroundImage = [backgroundImage resizableImageWithCapInsets:imageInset];
            
            [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            break;
        }
            
        case VietComboStyleAndroidLightBlue:
        {
            UIImage *backgroundImage = [UIImage imageNamed:@"vietcb_lblue"];
            UIEdgeInsets imageInset = UIEdgeInsetsMake(0, backgroundImage.size.width/2,
                                                       backgroundImage.size.height, backgroundImage.size.width/2);
            backgroundImage = [backgroundImage resizableImageWithCapInsets:imageInset];
            
            [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            break;
        }
            
        case VietComboStyleDefault:
        {
            UIImage *backgroundImage = [UIImage imageNamed:@"vietcb_down"];
            UIEdgeInsets imageInset = UIEdgeInsetsMake(0, backgroundImage.size.width/2,
                                                       backgroundImage.size.height, backgroundImage.size.width/2);
            
            backgroundImage = [backgroundImage resizableImageWithCapInsets:imageInset];
            
            [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            break;
        }
            
        default:
        {
            
            break;
        }
    }
    
    //
    //Set background
//    UIImage *bgImage = [UIImage imageNamed:@"vietcombo_gray"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, bgImage.size.width/2, bgImage.size.height, bgImage.size.width/2)];
//    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
}

@end
