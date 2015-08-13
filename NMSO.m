function [xBest, yBest] = NMSO(ftarget, func, dim, numEvaluations, maxRange, minRange, demo)
% Function NMSO 
%  Naive Multi-Scale Optimization Algorithm
% Input:
%	ftarget : NMSO stops if it hits a value less than ftarget, set to -inf if you wish to deactivate this feature
%   func    : the function handler such that y= func(x)
%   dim     : the dimensionality of the problem space
%   numEvaluations : number of evaluations
%   maxRange : the maximum of the search space, a single value applied to all the variables
%   minRange : the minimum of the search space, applies to all the decision variables.
%   demo : 0 , normal operating mode; 1, demo for 1-D problem; 2, demo for 2-D problem. (1 and 2 override all other inputs)
%  Author : Abdullah Al-Dujaili



%---------------------------------------------------
% For demo purpose:
%---------------------------------------------------
if (demo == 1)
	close all;
	func = @(x) 0.5 * (sin(23*(x-0.1)) .* sin(27*x)) + 0.5; % spherical function
	dim = 1;
	maxRange = 1;
	minRange = 0;
	numEvaluations = 100;
elseif (demo == 2)
	close all;
	func = @(x) sum((x-0.3473).^2); % spherical function
	dim = 2;
	maxRange = 1;
	minRange = 0;
	numEvaluations = 100;
	[x1,x2]=meshgrid(0:0.05:1);
	z = func([x1(:),x2(:)]');
	surf(x1,x2,reshape(z,[21 21]),'EdgeColor','none')
	xlim([minRange maxRange]);
	ylim([minRange maxRange])
    view(0,-90)
	hold on;
end
%---------------------------------------------------
% Parameter Settings
%---------------------------------------------------
opts.NUM_FOLDS = 3;
opts.DX = 1e-8 * max(maxRange-minRange) * dim;
opts.DF = 1e-8 * dim;
opts.BASKET_VISIT_TH = 100 * dim; % how many evaluation before visiting the basket (basket contains the node that are exploitated enough, i.e. leaves of the last expanded node in an expansion)
%---------------------------------------------------
% Other Settings
%---------------------------------------------------
% folds and range
opts.MAX_RANGE = maxRange * ones(dim,1);
opts.MIN_RANGE = minRange * ones(dim,1);
opts.MIDDLE_CELL = ceil(opts.NUM_FOLDS/2);
opts.IS_EVEN_FOLDS = (mod(opts.NUM_FOLDS,2) == 0);
opts.INV_NUM_FOLDS = 1/opts.NUM_FOLDS;


%---------------------------------------------------
% Root initialization
%---------------------------------------------------
root.bc.minX = opts.MIN_RANGE;
root.bc.maxX = opts.MAX_RANGE;
root.x = mean([root.bc.minX root.bc.maxX],2);
root.y = func(root.x);
root.DF = inf;
root.basketCount = inf;


opts.minDepth=1;

xBest = root.x;
yBest = root.y;


% set of nodes
nodes{1} = root;
h = opts.minDepth-1;


% visualize the tree in 1-D
if (demo == 1)
	x1 = 0:0.01:1;
	y1 = 0.5 * (sin(500*x1) .* sin(27*x1)) + 0.5 + 0.7 *(abs(x1-0.4)).^(0.5);
	plot(x1,y1);
	ylim([-1 5]);
	hold on;
	scatter(root.x,5);
end
%---------------------------------------------------
% Choosing the splitting index
%---------------------------------------------------
% training sample data to choose the splitting indices:
samples = [-1/(2*opts.NUM_FOLDS)*(maxRange-minRange)*eye(dim); 1/(2*opts.NUM_FOLDS)*(maxRange-minRange)*eye(dim)]+ ((maxRange-minRange)/2 + minRange) * ones(2*dim,dim);
samplesy = zeros(2*dim,1);
for i = 1 : dim
	samplesy(i) = func(samples(i,:)');
	samplesy(i+dim) = func(samples(i+dim,:)');
end
% sort and reflect:
y2 = abs([samplesy(1:dim)-samplesy(dim+1:end)]);
split_idx = 1:dim;
[~,idx]= sort(y2,'descend');
split_idx = split_idx(idx);
opts.numFEs = 1 + 2*dim;


%---------------------------------------------------
% work till you run out of FEs
%---------------------------------------------------
while(true)
	% choose node to be expanded
	%if (opts.numFEs > 359)
	%	keyboard
	%end
	h = h + 1;
	[~,idx] = min([nodes{h}.y]);
	node = nodes{h}(idx);
	% check if it is a basket visiting
	if (node.basketCount < opts.BASKET_VISIT_TH)
		node.basketCount = node.basketCount + 1;
		nodes{h}(idx)=node;
		% check other nodes in the level
		[~,idx]=sort([nodes{h}.y]);
		flag = true;
		for id = 2: length(idx)
			node = nodes{h}(idx(id));
			if (node.basketCount < opts.BASKET_VISIT_TH)
				node.basketCount = node.basketCount + 1;
				nodes{h}(idx(id))=node;
			else
				idx = idx(id);
				flag = false;
				break;
			end
		end
		if (flag) % if there is no other node at this level continue
			continue;
		end
	end
	nodes{h}(idx)=[];
	% check if empty:
	if (isempty(nodes{h}) && (h == opts.minDepth))
		opts.minDepth = opts.minDepth + 1;
	end
	% choose splitting index
	idx = mod(h -1, dim) + 1; 
	d = split_idx(idx);
	%d = dim(idx);
    r = (node.bc.maxX(d) - node.bc.minX(d)) * opts.INV_NUM_FOLDS;
    newNodes = repmat(node, 1,opts.NUM_FOLDS);
    %keyboard
    for f = 1 : opts.NUM_FOLDS % children process
        newNodes(f).bc.minX = node.bc.minX;
        newNodes(f).bc.maxX = node.bc.maxX;
        newNodes(f).bc.minX(d) = newNodes(f).bc.minX(d) + r * (f-1);
        newNodes(f).bc.maxX(d) = newNodes(f).bc.minX(d) + r;
        newNodes(f).x = mean([newNodes(f).bc.minX newNodes(f).bc.maxX],2);
		newNodes(f).basketCount = inf; % basket count
        if (f == opts.MIDDLE_CELL && ~opts.IS_EVEN_FOLDS)
          newNodes(f).x = node.x;
          newNodes(f).y = node.y;
		else
          newNodes(f).x = mean([newNodes(f).bc.minX newNodes(f).bc.maxX],2);
		  newNodes(f).y = func(newNodes(f).x);
		  opts.numFEs = opts.numFEs + 1;
		  % check fitness value and terminating condition:
		  if (yBest > newNodes(f).y)
            yBest = newNodes(f).y;
            xBest = newNodes(f).x;
			if (yBest < ftarget)
				return;
			end
		  end
		  if (opts.numFEs >= numEvaluations)
            return;
          end
        end
        % plot
       if (demo)
			figure(1)
			if (demo == 2)
				xlim([opts.MIN_RANGE(1) opts.MAX_RANGE(1)]);
				ylim([opts.MIN_RANGE(2) opts.MAX_RANGE(2)])
				scatter(newNodes(f).x(1),newNodes(f).x(2),'.k')
				rectangle('Position',[newNodes(f).bc.minX(1), newNodes(f).bc.minX(2), newNodes(f).bc.maxX(1)-newNodes(f).bc.minX(1), newNodes(f).bc.maxX(2)-newNodes(f).bc.minX(2)]);
				hold on
				pause(0.1);
			elseif(demo == 1)
				plot([newNodes(f).x node.x],[5-0.5*h 5.5-0.5*h])
				hold on
				scatter(newNodes(f).x, 5-0.5*h,'o')
				hold on
				pause(0.1);
			end
       end
    end % end children process
    % update DF,
	if (mod(h -1 ,dim) == 0)
      DF = abs(-newNodes(max(1,opts.MIDDLE_CELL - 1)).y + newNodes(opts.MIDDLE_CELL + 1).y );
	  for f= 1:opts.NUM_FOLDS
        newNodes(f).DF =  DF;
      end
	else
		DF = node.DF; 
		for f=1:opts.NUM_FOLDS
			newNodes(f).DF =  max(DF, abs(-newNodes(max(1,opts.MIDDLE_CELL - 1)).y+ newNodes(opts.MIDDLE_CELL + 1).y));
		end
		DF = newNodes(f).DF;     
	end
	% check if restart is needed
	if ((mod(h,dim) == 0) && (r <= opts.DX) && (DF <= opts.DF))
	  %opts.numSequnces = opts.numSequnces + 1;
	  %disp('restarting');
	  % put them in the shopping basket
	  for f= 1:opts.NUM_FOLDS
        newNodes(f).basketCount = 0;
      end
  	  if (length(nodes)>h)
		nodes{h+1} = [nodes{h+1} newNodes]; 
	  else
		nodes{h+1} = newNodes;
	  end
	  h = opts.minDepth - 1;
	else % put these nodes
	% put the new nodes
		if (length(nodes)>h)
			nodes{h+1} = [nodes{h+1} newNodes]; 
		else
			nodes{h+1} = newNodes;
		end
	end 
end % end for h



end