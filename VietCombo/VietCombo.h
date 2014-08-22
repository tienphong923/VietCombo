//
//  VietCombo.h
//  VietCombo
//
//  Created by tienphong923@gmail.com on 8/30/13.
//  Copyright (c) 2013 Z-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    VietComboStyleNone,
    VietComboStyleDefault,
    VietComboStyleAndroidGray,
    VietComboStyleAndroidLightBlue
} VietComboStyle;

@protocol VietComboDelegate;

@interface VietCombo : UIButton <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL showShadow;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) VietComboStyle vietComboStyle;

@property (assign, nonatomic) id<VietComboDelegate>delegate;

@end



@protocol VietComboDelegate <NSObject>
- (void)vietCombo:(VietCombo *)vietCombo didSelectItem:(NSDictionary *)selectedItem;
@end