function [rot]=ParselyParser(id,parse)
    data=urlread(['http://parsely.io/parser/view/' num2str(id) '/' num2str(parse)]);
    url=['http://parsely.io/parser/view/' num2str(id) '/' num2str(parse)];
    a=strfind(data,'<div role="tabpanel" class="tab-pane" id="rotation">');
    b=strfind(data,'<tbody>');
    c=min(b(b>a));
    d=strfind(data,'</tbody>');
    e=min(d(d>c));
    tbl=data(c+10:e);
    cbtl=strfind(tbl,'</tr>');
    cbtl=[0,cbtl];
    rot=cell(1,numel(cbtl));
    for i = 1:numel(cbtl)-1;
        z=tbl(cbtl(i)+9:cbtl(i+1));
        rot{i}=z(strfind(z,'</td><td>')+9:end-6);
    end
    if(numel(rot{end})==0)
        rot=rot(1:end-1);
    end
    fprintf('NOTE: Sometimes Parsely does not have the first ability in the rotation.\nIt is up to you to perform a sanity check\n'); 
    
end