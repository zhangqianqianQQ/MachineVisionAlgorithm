#include "mex.h"
#include "matrix.h"
#include <stack>
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    int r = 0;
    char bestVar[100];
    mxArray *pLeftChild, *pRightChild;
    
    mxArray *pIsTerminal = mxGetProperty( prhs[0], r, "isTerminal" );
    mxLogical *isTerminal = mxGetLogicals( pIsTerminal );
    mxArray *pBestVar = mxGetProperty( prhs[0], r, "bestVar" );
    mxGetString( pBestVar, bestVar, 100 );
    mexPrintf( "%s, %s\n", bestVar, (isTerminal[0] ? "true" : "false") );

    pRightChild = mxGetProperty( prhs[0], r, "rightChild" );
    pLeftChild = mxGetProperty( prhs[0], r, "leftChild" );
    
    stack<mxArray*> toVisitNode;
    if( !mxIsEmpty(pRightChild) )
        toVisitNode.push( pRightChild );
    if( !mxIsEmpty(pLeftChild) )
        toVisitNode.push( pLeftChild );
    
    while( !toVisitNode.empty() )
    {
        mxArray *pNode = toVisitNode.top();
        toVisitNode.pop();
        
        pIsTerminal = mxGetProperty( pNode, 0, "isTerminal" );
        isTerminal = mxGetLogicals( pIsTerminal );
        pBestVar = mxGetProperty( pNode, 0, "bestVar" );
        mxGetString( pBestVar, bestVar, 100 );
        mexPrintf( "%s, %s\n", bestVar, (isTerminal[0] ? "terminal" : "non-terminal") );

        pRightChild = mxGetProperty( pNode, 0, "rightChild" );
        pLeftChild = mxGetProperty( pNode, 0, "leftChild" );        
        
        if( !mxIsEmpty(pRightChild) )
            toVisitNode.push( pRightChild );
        if( !mxIsEmpty(pLeftChild) )
            toVisitNode.push( pLeftChild );       
    }
}