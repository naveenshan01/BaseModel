# BaseModel
A base class which can be used while creating model class in ios. 
Which helps to map the dictionary to model class properties and create a dictionary from model properties during runtime.

Which helps developer to map the dictionary key value to property value without much code.

```
To map dictionary to model use,
- (instancetype)initWithContent:(NSDictionary *)content;
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;

Eg : 
[User objectFromDictionary:@{@"firstName" : @"Naveen", @"lastName" : @"shan"}]; or
User *user = [[User alloc] initWithContent:@{@"firstName" : @"Naveen", @"lastName" : @"shan"}];

Where User,
@interface User : BaseModel

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end

@implementation User
@end
```

```
To get dictionary with model properies use,
- (NSMutableDictionary *)dictionary;

Eg :
User *user = [[User alloc] init];
user.firstName = @"Naveen";
user.lastName = @"Shan";

NSDictionary *userDetails = [user dictionary];
// userDetails = @{@"firstName" : @"Naveen", @"lastName" : @"shan"}
```

In order to do map the content during runtime and reusable we need to handle following cases,
1. Option to prevent a property from mapping. - Private Properties
2. Map an array type property with a model in which array values need to be mapped. - Array Class Mapping
3. Need to handle a model class support as property inside a model class. - Dictionary Class Mapping
4. Need to provide flexibility to write the model specific key instead of forcing the dictionary key as property name.

To handle this cases I wrote 4 helper methods, which need to be override in the class and return the values.
```
+ (NSArray *)privateProperties;
+ (NSDictionary *)arrayClassMapping;
+ (NSDictionary *)dictionaryClassMapping;
+ (NSDictionary *)propertiesMap;

Eg:

+ (NSArray *)privateProperties {
   return @[@"nickName"];
}

+ (NSDictionary *)arrayClassMapping  {
    return @{@"packageLists" : [PackageList class]]};
}

+ (NSDictionary *)dictionaryClassMapping  {
    return @{@"offerDetails" : [OfferDetails class]};
}

+ (NSDictionary *)propertiesMap {
    return @{@"packageGroups" : @"package_group"};
}

```



