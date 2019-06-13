classdef RFTreeNode < handle
    properties(SetAccess = public)
        isTerminal
        nodeClass
        bestVar
        bestSplit
        leftChild
        rightChild
    end
    
    methods
%         function node = RFTreeNode()
%             node.isTerminal = false;
%             node.nodeClass = 0;
%             node.bestVar = 0;
%             node.bestSplit = 0;
%         end
        
        function node = RFTreeNode( isTerminal_, nodeClass_, bestVar_, bestSplit_ )
            node.isTerminal = isTerminal_;
            node.nodeClass = nodeClass_;
            node.bestVar = bestVar_;
            node.bestSplit = bestSplit_;
        end
        
%         function insertLeftChild( parentNode, newNode )
%             if ~isempty(parentNode.leftChild)
%                 error( 'There already exists a left child for the specified parent node.' );
%             end
%             parentNode.leftChild = newNode;
%         end
%         
%         function insertRightChild( parentNode, newNode )
%             if ~isempty(parentNode.rightChild)
%                 error( 'There already exists a right child for the specified parent node.' );
%             end
%             parentNode.rightChild = newNode;
%         end
    end % end of methods of class RFTreeNode
end % end of classdef