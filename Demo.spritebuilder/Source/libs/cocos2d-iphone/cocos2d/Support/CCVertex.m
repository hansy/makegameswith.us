/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 ForzeField Studios S.L. http://forzefield.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCVertex.h"
#import "CGPointExtension.h"
#import "../CCMacros.h"

void CCVertexLineToPolygon(CGPoint *points, float stroke, ccVertex2F *vertices, NSUInteger offset, NSUInteger nuPoints)
{
    nuPoints += offset;
    if(nuPoints<=1) return;

    stroke *= 0.5f;

    NSUInteger idx;
    NSUInteger nuPointsMinus = nuPoints-1;

    for(NSUInteger i = offset; i<nuPoints; i++)
    {
        idx = i*2;
        CGPoint p1 = points[i];
        CGPoint perpVector;

        if(i == 0)
            perpVector = ccpPerp(ccpNormalize(ccpSub(p1, points[i+1])));
        else if(i == nuPointsMinus)
            perpVector = ccpPerp(ccpNormalize(ccpSub(points[i-1], p1)));
        else
        {
            CGPoint p2 = points[i+1];
            CGPoint p0 = points[i-1];

            CGPoint p2p1 = ccpNormalize(ccpSub(p2, p1));
            CGPoint p0p1 = ccpNormalize(ccpSub(p0, p1));

            // Calculate angle between vectors
            float angle = acosf(ccpDot(p2p1, p0p1));

            if(angle < CC_DEGREES_TO_RADIANS(70))
                perpVector = ccpPerp(ccpNormalize(ccpMidpoint(p2p1, p0p1)));
            else if(angle < CC_DEGREES_TO_RADIANS(170))
                perpVector = ccpNormalize(ccpMidpoint(p2p1, p0p1));
            else
                perpVector = ccpPerp(ccpNormalize(ccpSub(p2, p0)));
        }
        perpVector = ccpMult(perpVector, stroke);

        vertices[idx] = (ccVertex2F) {p1.x+perpVector.x, p1.y+perpVector.y};
        vertices[idx+1] = (ccVertex2F) {p1.x-perpVector.x, p1.y-perpVector.y};
    }

    // Validate vertexes
    offset = (offset==0) ? 0 : offset-1;
    for(NSUInteger i = offset; i<nuPointsMinus; i++)
    {
        idx = i*2;
        const NSUInteger idx1 = idx+2;

        ccVertex2F p1 = vertices[idx];
        ccVertex2F p2 = vertices[idx+1];
        ccVertex2F p3 = vertices[idx1];
        ccVertex2F p4 = vertices[idx1+1];

        float s;
        //BOOL fixVertex = !ccpLineIntersect(ccp(p1.x, p1.y), ccp(p4.x, p4.y), ccp(p2.x, p2.y), ccp(p3.x, p3.y), &s, &t);
        BOOL fixVertex = !CCVertexLineIntersect(p1.x, p1.y, p4.x, p4.y, p2.x, p2.y, p3.x, p3.y, &s);
        if(!fixVertex)
            if (s<0.0f || s>1.0f)
                fixVertex = YES;

        if(fixVertex)
        {
            vertices[idx1] = p4;
            vertices[idx1+1] = p3;
        }
    }
}

BOOL CCVertexLineIntersect(float Ax, float Ay,
                               float Bx, float By,
                               float Cx, float Cy,
                               float Dx, float Dy, float *T)
{
    float  distAB, theCos, theSin, newX;

    // FAIL: Line undefined
    if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return NO;

    //  Translate system to make A the origin
    Bx-=Ax; By-=Ay;
    Cx-=Ax; Cy-=Ay;
    Dx-=Ax; Dy-=Ay;

    // Length of segment AB
    distAB = sqrtf(Bx*Bx+By*By);

    // Rotate the system so that point B is on the positive X axis.
    theCos = Bx/distAB;
    theSin = By/distAB;
    newX = Cx*theCos+Cy*theSin;
    Cy  = Cy*theCos-Cx*theSin; Cx = newX;
    newX = Dx*theCos+Dy*theSin;
    Dy  = Dy*theCos-Dx*theSin; Dx = newX;

    // FAIL: Lines are parallel.
    if (Cy == Dy) return NO;

    // Discover the relative position of the intersection in the line AB
    *T = (Dx+(Cx-Dx)*Dy/(Dy-Cy))/distAB;

    // Success.
    return YES;
}
