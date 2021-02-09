#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

int main(int argc, const char** argv)
{
    NSString *text = @"Got def manager: %@";
    NSFileManager* def = [NSFileManager defaultManager];
    NSLog(text, def);
    
    return 0;
}
