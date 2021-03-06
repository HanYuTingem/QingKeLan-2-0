//
//  DishesListCell.m
//  PRJ_NiceFoodModule
//
//  Created by 刘雅楠 on 15/7/15.
//  Copyright (c) 2015年 Mike. All rights reserved.
//

#import "DishesListCell.h"
#import "dishesList.h"


@implementation DishesListCell

- (DishesListCell *)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 100, 20)];
        
        [self.contentView addSubview:_name];
        
        
        _cost = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 100, 20)];
        [_cost setTextColor:RGBACOLOR(230, 60, 82, 1)];
        [self.contentView addSubview:_cost];
 
        _numberDishView = [[NumberDishView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.7 - 125, 25, 110, 40)];
        [self.contentView addSubview:_numberDishView];
        
    }
    return self;
}

+ (DishesListCell *)cellWithTableView:(UITableView *)tabelView{
    
    static NSString * ident = @"dishesListCell";
    
    DishesListCell *cell = [tabelView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        
        cell = [[DishesListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
        
    }
    return cell;
}

- (void)setModel:(dishesList *)model{
    _model = model;
    
    _name.text = _model.contentName;
    
    NSString *cost = [NSString stringWithFormat:@"¥ %@", _model.price];
    _cost.text = cost;
    
    
    _numberDishView.model = model;
   [_numberDishView reloadCopiesNumber];
    
    
}

@end
