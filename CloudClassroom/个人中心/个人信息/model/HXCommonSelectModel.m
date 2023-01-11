//
//  HXCommonSelectModel.m
//  CloudClassroom
//
//  Created by mac on 2023/1/11.
//

#import "HXCommonSelectModel.h"

@implementation HXCommonSelectModel

-(NSString *)content{
    if (![HXCommonUtil isNull:self.politicalName]) {
        return self.politicalName;
    }else if(![HXCommonUtil isNull:self.nationName]){
        return self.nationName;
    }else{
        return _content;
    }
}

-(NSString *)contentId{
    if (![HXCommonUtil isNull:self.politicalState_id]) {
        return self.politicalState_id;
    }else if(![HXCommonUtil isNull:self.nation_id]){
        return self.nationName;
    }else{
        return _contentId;
    }
}

@end
