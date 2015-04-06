#import "VoronoiView.h"
#include "VoronoiDiagramGenerator.h"

@implementation VoronoiView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        points = [NSMutableArray new];
    }
    
    return self;
}

- (void)dealloc
{
    [points release];
    [super dealloc];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    bool doAdd = true;
    
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    for (NSValue* pv in points)
    {
        NSPoint other = [pv pointValue];
        float dx = other.x-point.x;
        float dy = other.y-point.y;
        float sqareDist = dx*dx+dy*dy;
        
        if (sqareDist < 0.05)
        {
            doAdd=false;
        }
    }
    
    if (doAdd)
    {
        [points addObject:[NSValue valueWithPoint:point]];
        [self setNeedsDisplay:YES];
    }

    

}

- (void)drawRect:(NSRect)dirtyRect
{
    vdg::VoronoiDiagramGenerator generator;
    NSUInteger size = [points count];    
    float* xValues = new float[size];
    float* yValues = new float[size];
    
    // bool generateVoronoi(float *xValues, float *yValues, int numPoints, float minX, float maxX, float minY, float maxY, float minDist=0);
    
    [[NSColor redColor] set];
    
    float pointRadius = 3;
    NSUInteger counter = 0;
    for (NSValue* pv in points)
    {
        NSPoint p = [pv pointValue];
        xValues[counter]=p.x;
        yValues[counter]=p.y;
        counter++;
        
        NSBezierPath* ppath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(p.x-pointRadius, p.y-pointRadius, 2*pointRadius, 2*pointRadius)];
        [ppath fill];
    }
    
    bool success = generator.generateVoronoi(xValues, yValues, int(size), 0, [self bounds].size.width, 0, [self bounds].size.height);
    generator.resetIterator();

    if (success)
    {   
        [[NSColor blackColor] set];       
    
        float x1, y1, x2, y2;
        while (generator.getNext(x1, y1, x2, y2))
        {
            NSBezierPath* line = [NSBezierPath bezierPath];
            [line moveToPoint:NSMakePoint(x1, y1)];
            [line lineToPoint:NSMakePoint(x2, y2)];
            [line stroke];
        }
        
    }
    
    
    delete xValues;
    delete yValues;
}

@end
