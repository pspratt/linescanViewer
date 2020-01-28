function img_data = parse_linescan_xml(xmlfile)

xdoc = xmlread(xmlfile);

%Go through the tree
node = parse_node(xdoc, 'PVScan');

%Parse version and date attributes
theAttributes = getAttributes(node);
numAttributes = getLength(theAttributes);
for count = 1:numAttributes
    str = toCharArray(toString(item(theAttributes,count-1)))';
    k = strfind(str,'=');
    attr_name = str(1:(k(1)-1));
    attributes.(attr_name) = str((k(1)+2):(end-1));
end
img_data.praire_version = attributes.version;
img_data.date = attributes.date;
img_data.numFrames = number_target_node(node, 'Sequence');
node = parse_node(node, 'Sequence');
node = parse_node(node, 'Frame');

%Parse the channels
img_data.ch1 = [];
img_data.ch2 = [];
img_data.ch3 = [];
img_data.ch4 = [];
childNodes = getChildNodes(node);
numChildNodes = getLength(childNodes);
for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
    if strcmp('File',toCharArray(getNodeName(theChild))')
        if hasAttributes(theChild)
           theAttributes = getAttributes(theChild);
           numAttributes = getLength(theAttributes);
           for count = 1:numAttributes
                str = toCharArray(toString(item(theAttributes,count-1)))';
                k = strfind(str,'='); 
                attr_name = str(1:(k(1)-1));                                  
                attributes.(attr_name) = str((k(1)+2):(end-1));
           end    
           
           if strcmp(attributes.channel,'1')
               img_data.ch1 = attributes.channelName;
           elseif strcmp(attributes.channel,'2')
               img_data.ch2 = attributes.channelName;
           elseif strcmp(attributes.channel,'3')
               img_data.ch3 = attributes.channelName;
           elseif strcmp(attributes.channel,'4')               
               img_data.ch4 = attributes.channelName;
           end           
        end
    end
    
end

node = parse_node(node, 'PVStateShard');
%Parse imaging data
childNodes = getChildNodes(node);
numChildNodes = getLength(childNodes);
for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
    if hasAttributes(theChild)
       theAttributes = getAttributes(theChild);
       numAttributes = getLength(theAttributes);
       for count = 1:numAttributes
            str = toCharArray(toString(item(theAttributes,count-1)))';
            k = strfind(str,'='); 
            attr_name = str(1:(k(1)-1));                                  
            attributes.(attr_name) = str((k(1)+2):(end-1));
       end    
       img_data.(attributes.key) = attributes.value;
    end
    
end

function node = parse_node(node, target)
childNodes = getChildNodes(node);
numChildNodes = getLength(childNodes);
for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
    if strcmp(target,toCharArray(getNodeName(theChild))')
        node = theChild;
        break;
    end
end
end

function numNodes = number_target_node(node, target)
childNodes = getChildNodes(node);
numChildNodes = getLength(childNodes);
numNodes = 0;
for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
%     disp(toCharArray(getNodeName(theChild))');
    if strcmp(target,toCharArray(getNodeName(theChild))')
        numNodes = numNodes +1;
    end
end
end

end