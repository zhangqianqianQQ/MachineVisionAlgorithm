#include "mex.h"
#include "matrix.h"
#include <stack>
using std::stack;

// tree = mexFunction( treemap, bestvar, bestsplit, nodestatus, nodeclass );
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    double *treemap, *bestvar, *bestsplit, *nodestatus, *nodeclass;
    
    treemap = static_cast<double*>( mxGetData(prhs[0]) ); 
    bestvar = static_cast<double*>( mxGetData(prhs[1]) );
    bestsplit = static_cast<double*>( mxGetData(prhs[2]) );
    nodestatus = static_cast<double*>( mxGetData(prhs[3]) );
    nodeclass = static_cast<double*>( mxGetData(prhs[4]) );
    
    int nrnodes = mxGetM( prhs[1] );
    
    int k = 0;
    stack<int> toVisitNode;
    toVisitNode.push( k );
    
    while( !toVisitNode.empty() )
    {
        int ix = toVisitNode.top();
        toVisitNode.pop();
        
        
    }
}